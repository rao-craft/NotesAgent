//  WHAT: The `categories` lines: the categories the views start with, written into `NotesCategories`.
//
//            general = General brown          the one new notes go in and a deleted category's notes move to
//            memory = Memory green            notes shown only under the memories button (none when left out)
//            Space brown                      a listed category: its name, then its colour
//            "Machine Learning" brown         a name of several words, quoted or not
//            color = gray                     a new category's colour, and that of one a note names that no line lists
//
//        A colour is a SwiftUI colour's name (red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple,
//        pink, brown, gray, black, white), `accent`, or `#RRGGBB`; a line with none takes `color`'s.

import Foundation

struct CategorySpec: Sendable, Equatable {
    struct Named: Sendable, Equatable {
        let name: String
        /// Swift for the colour, or nil for `color`'s.
        let color: String?
    }

    var general = Named(name: "General", color: nil)
    var memory: Named?
    var listed: [Named] = []
    /// Swift for a new category's colour.
    var unlisted = "Color.gray"
}

enum CategoryLine {
    static let colorNames = ["red", "orange", "yellow", "green", "mint", "teal", "cyan", "blue", "indigo", "purple", "pink",
                             "brown", "gray", "grey", "black", "white"]

    /// The categories of a call; a line it cannot read adds its reason.
    static func read(_ lines: [String]?, problems: inout [String]) -> CategorySpec {
        var spec = CategorySpec()
        var said: Set<String> = []
        var names: Set<String> = []
        for line in lines ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if let equals = LineSplit.firstTop(text, "=") {
                    let key = text[..<equals].trimmingCharacters(in: .whitespaces)
                    let value = text[text.index(after: equals)...].trimmingCharacters(in: .whitespaces)
                    guard !value.isEmpty else { throw NotesError.line(line, "`\(key)` has `=` and no value") }
                    switch key.lowercased() {
                    case "general", "memory":
                        guard said.insert(key.lowercased()).inserted else { throw NotesError.line(line, "`\(key)` is said twice") }
                        let named = try self.named(String(value), line: line)
                        guard names.insert(named.name.lowercased()).inserted else { throw NotesError.line(line, "`\(named.name)` is named twice") }
                        if key.lowercased() == "general" { spec.general = named } else { spec.memory = named }
                    case "color", "colour", "new":
                        guard said.insert("color").inserted else { throw NotesError.line(line, "`color` is said twice") }
                        guard let swift = color(String(value)) else { throw NotesError.line(line, notAColor(String(value))) }
                        spec.unlisted = swift
                    default:
                        // `Name = colour`, the name before the `=`.
                        let name = try KeyLine.text(String(key))
                        guard !name.isEmpty else { throw NotesError.line(line, "it names no category: `Space brown`") }
                        guard let swift = color(String(value)) else { throw NotesError.line(line, notAColor(String(value))) }
                        guard names.insert(name.lowercased()).inserted else { throw NotesError.line(line, "`\(name)` is named twice") }
                        spec.listed.append(.init(name: name, color: swift))
                    }
                } else {
                    let named = try self.named(text, line: line)
                    guard names.insert(named.name.lowercased()).inserted else { throw NotesError.line(line, "`\(named.name)` is named twice") }
                    spec.listed.append(named)
                }
            } catch { problems.append("categories \(error)") }
        }
        return spec
    }

    /// `"Machine Learning" brown`, `Machine Learning brown`, `Space`: a name and, when its last word is one, a colour.
    static func named(_ text: String, line: String) throws -> CategorySpec.Named {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("\"") {
            var index = trimmed.index(after: trimmed.startIndex), escaped = false
            while index < trimmed.endIndex {
                let character = trimmed[index]
                if escaped { escaped = false } else if character == "\\" { escaped = true } else if character == "\"" { break }
                index = trimmed.index(after: index)
            }
            guard index < trimmed.endIndex else { throw NotesError.line(line, "the quote is not closed") }
            let name = try KeyLine.text(String(trimmed[...index]))
            let rest = trimmed[trimmed.index(after: index)...].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { throw NotesError.line(line, "the category's name is empty") }
            if rest.isEmpty { return .init(name: name, color: nil) }
            guard let swift = color(rest) else { throw NotesError.line(line, notAColor(rest)) }
            return .init(name: name, color: swift)
        }
        let words = trimmed.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !words.isEmpty else { throw NotesError.line(line, "it names no category: `Space brown`") }
        if words.count > 1, let swift = color(words[words.count - 1]) {
            return .init(name: words.dropLast().joined(separator: " "), color: swift)
        }
        return .init(name: words.joined(separator: " "), color: nil)
    }

    /// Swift for a colour token, or nil when it is not one.
    static func color(_ token: String) -> String? {
        let word = token.trimmingCharacters(in: .whitespaces)
        let lower = word.lowercased()
        if lower == "grey" { return "Color.gray" }
        if colorNames.contains(lower) { return "Color.\(lower)" }
        if lower == "accent" { return "NotesLook.accent" }
        var hex = lower
        if hex.hasPrefix("#") { hex.removeFirst() } else { return nil }
        guard hex.count == 6, let number = UInt32(hex, radix: 16) else { return nil }
        func part(_ shift: UInt32) -> String {
            let value = Double((number >> shift) & 0xFF) / 255
            return String(format: "%.3f", value)
        }
        return "Color(red: \(part(16)), green: \(part(8)), blue: \(part(0)))"
    }

    private static func notAColor(_ token: String) -> String {
        "`\(token)` is not a colour: a SwiftUI colour's name (\(colorNames.filter { $0 != "grey" }.joined(separator: ", "))), `accent`, or `#RRGGBB`"
    }
}
