//  WHAT: The `key = value` line every keyed field shares (`strings`, `symbols`, `sizes`, `motion`, `look`, `launch`):
//        cut at the first `=` outside quotes, and a value read as text, quoted or bare.
//
//            library.title = Library
//            category.deleteMessage = "Are you sure?\nAll notes in the \"{name}\" category will be moved."
//
//        In a value, `\n` is a line break, `\"` a quote and `\\` a backslash; a value in quotes keeps its spaces.

import Foundation

enum KeyLine {
    /// The key and the raw value (trimmed, quotes kept), or why the line is not `key = value`.
    static func split(_ line: String, example: String) throws -> (key: String, value: String) {
        let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw NotesError.line(line, "it is empty") }
        guard let equals = LineSplit.firstTop(text, "=") else {
            throw NotesError.line(line, "a line is `key = value`, like `\(example)`, and this has no `=`")
        }
        let key = text[..<equals].trimmingCharacters(in: .whitespaces)
        let value = text[text.index(after: equals)...].trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { throw NotesError.line(line, "it names no key: `\(example)`") }
        guard !value.isEmpty else { throw NotesError.line(line, "`\(key)` has `=` and no value") }
        return (key, value)
    }

    /// A value as text: the quotes taken off a quoted one, and `\n`, `\t`, `\"`, `\\` read in either.
    static func text(_ value: String) throws -> String {
        var body = value
        if body.hasPrefix("\"") {
            guard body.count >= 2, body.hasSuffix("\""), !body.hasSuffix("\\\"") || body.hasSuffix("\\\\\"") else {
                throw NotesError.line(value, "the quote is not closed")
            }
            body = String(body.dropFirst().dropLast())
        }
        var out = ""
        var escaped = false
        for character in body {
            if escaped {
                switch character {
                case "n": out.append("\n")
                case "t": out.append("\t")
                default: out.append(character)
                }
                escaped = false
            } else if character == "\\" {
                escaped = true
            } else {
                out.append(character)
            }
        }
        if escaped { out.append("\\") }
        return out
    }

    /// A list value, `a | b | c` (each one quoted or bare), as its items.
    static func list(_ value: String) throws -> [String] {
        var items: [String] = [], current = "", quoted = false, escaped = false
        for character in value {
            if quoted {
                current.append(character)
                if escaped { escaped = false } else if character == "\\" { escaped = true } else if character == "\"" { quoted = false }
                continue
            }
            if character == "\"" { quoted = true; current.append(character); continue }
            if character == "|" { items.append(current); current = ""; continue }
            current.append(character)
        }
        items.append(current)
        let trimmed = items.map { $0.trimmingCharacters(in: .whitespaces) }
        guard !trimmed.contains(where: \.isEmpty) else { throw NotesError.line(value, "a list is `one | two | three`, and one of its items is empty") }
        return try trimmed.map(text)
    }
}
