//  WHAT: A template made into the app's file: each placeholder filled with the call's word, symbol, size or timing as
//        Swift, the file tidied, the kit's types renamed with the call's prefix. A template is Swift as the kit
//        writes it, with these placeholders where a call's value goes:
//
//            {{s:library.title}}         a string            "Library"
//            {{l:editor.titlePlaceholder}} a list of strings ["Title your note...", "Title your imagination..."]
//            {{y:library.new}}           a symbol's name     "plus"
//            {{n:grid.minimum}}          a number            160
//            {{m:library.filter}}        an animation, or seconds   .bouncy   0.6
//
//  PIN:  EVERY PLACEHOLDER NAMES A KEY OF `WordTable`, and an unknown one is a fault of the template, caught by the
//        tests before any call is made; a template that names none is written as it is.

import Foundation

enum TemplateRender {
    enum Failure: Error, Equatable, CustomStringConvertible {
        case unknown(String)
        var description: String {
            switch self { case .unknown(let placeholder): return "the template names `\(placeholder)`, which no table holds" }
        }
    }

    static let placeholder = #"\{\{([slynm]):([A-Za-z0-9_.]+)\}\}"#

    /// `source` with every placeholder filled from `words`, tidied.
    static func render(_ source: String, words: Words, replacing extra: [String: String] = [:]) throws -> String {
        guard let regex = try? NSRegularExpression(pattern: placeholder) else { return source }
        var out = ""
        var cursor = source.startIndex
        for match in regex.matches(in: source, range: NSRange(source.startIndex..., in: source)) {
            guard let whole = Range(match.range, in: source), let kindRange = Range(match.range(at: 1), in: source),
                  let keyRange = Range(match.range(at: 2), in: source) else { continue }
            out += source[cursor..<whole.lowerBound]
            let key = String(source[keyRange])
            out += try value(kind: source[kindRange], key: key, words: words, extra: extra)
            cursor = whole.upperBound
        }
        out += source[cursor...]
        return tidy(out.components(separatedBy: "\n"))
    }

    private static func value(kind: Substring, key: String, words: Words, extra: [String: String]) throws -> String {
        switch kind {
        case "s":
            guard var text = words.strings[key] else { throw Failure.unknown("s:" + key) }
            for (name, replacement) in extra { text = text.replacingOccurrences(of: "{\(name)}", with: replacement) }
            return SwiftLiteral.string(text)
        case "l":
            guard let items = words.lists[key] else { throw Failure.unknown("l:" + key) }
            return SwiftLiteral.array(items)
        case "y":
            guard let name = words.symbols[key] else { throw Failure.unknown("y:" + key) }
            return SwiftLiteral.string(name)
        case "n":
            guard let number = words.sizes[key] else { throw Failure.unknown("n:" + key) }
            return number
        default:
            guard let motion = words.motion[key] else { throw Failure.unknown("m:" + key) }
            return motion
        }
    }

    /// Every placeholder a template names, as `kind:key`.
    static func placeholders(in source: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: placeholder) else { return [] }
        return regex.matches(in: source, range: NSRange(source.startIndex..., in: source)).compactMap { match in
            guard let kind = Range(match.range(at: 1), in: source), let key = Range(match.range(at: 2), in: source) else { return nil }
            return "\(source[kind]):\(source[key])"
        }
    }

    /// The lines as a file: no trailing spaces, no run of blank lines and no blank line against a brace, one newline
    /// at the end.
    static func tidy(_ lines: [String]) -> String {
        var kept: [String] = []
        for (index, raw) in lines.enumerated() {
            var line = raw
            while line.last == " " || line.last == "\t" { line.removeLast() }
            if line.isEmpty {
                let next = lines[(index + 1)...].first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                let afterOpening = kept.last.map { $0.hasSuffix("{") } ?? true
                let beforeClosing = next.map { $0.trimmingCharacters(in: .whitespaces).hasPrefix("}") } ?? true
                if kept.last?.isEmpty == true || afterOpening || beforeClosing { continue }
            }
            kept.append(line)
        }
        return kept.joined(separator: "\n") + "\n"
    }

    /// `text` with each name in `names` (a whole word) given `prefix`: `NoteCard` → `KitNoteCard`.
    static func prefixing(_ text: String, names: [String], prefix: String) -> String {
        guard !prefix.isEmpty, !names.isEmpty else { return text }
        let pattern = "(?<![A-Za-z0-9_])(" + names.sorted { $0.count > $1.count }.map(NSRegularExpression.escapedPattern(for:)).joined(separator: "|") + ")(?![A-Za-z0-9_])"
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return expression.stringByReplacingMatches(in: text, range: range, withTemplate: NSRegularExpression.escapedTemplate(for: prefix) + "$1")
    }
}
