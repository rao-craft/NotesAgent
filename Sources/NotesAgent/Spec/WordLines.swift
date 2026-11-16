//  WHAT: The `strings`, `symbols`, `sizes` and `motion` lines read into `Words`: every key with the call's value or
//        its default, as the templates write it.
//
//            strings:  library.title = Library          editor.titlePlaceholder = Title your note... | Title it...
//            symbols:  library.new = square.and.pencil
//            sizes:    grid.minimum = 160               picker.detent = 0.6
//            motion:   library.filter = .spring(response: 0.4, dampingFraction: 0.8)      editor.deleteDelay = 0.6
//
//  PIN:  A LINE IS REFUSED WITH WHAT ITS FIELD TAKES: an unknown key names the keys near it, a size that is not a
//        number says so, an animation that is not one of SwiftUI's says which it reads.

import Foundation

/// Every word, symbol, size and timing a call writes, by key.
struct Words: Sendable, Equatable {
    var strings: [String: String]
    var lists: [String: [String]]
    var symbols: [String: String]
    /// Numbers as Swift writes them: `160`, `0.6`.
    var sizes: [String: String]
    /// An animation (`.bouncy`) or seconds (`0.6`).
    var motion: [String: String]

    static var defaults: Words {
        Words(strings: Dictionary(uniqueKeysWithValues: WordTable.strings.map { ($0.key, $0.value) }),
              lists: Dictionary(uniqueKeysWithValues: WordTable.lists.map { ($0.key, $0.value.components(separatedBy: " | ")) }),
              symbols: Dictionary(uniqueKeysWithValues: WordTable.symbols.map { ($0.key, $0.value) }),
              sizes: Dictionary(uniqueKeysWithValues: WordTable.sizes.map { ($0.key, $0.value) }),
              motion: Dictionary(uniqueKeysWithValues: WordTable.motion.map { ($0.key, $0.value) }))
    }
}

enum WordLines {
    /// The words of a call: the defaults with each line's value over them; a line it cannot read adds its reason.
    static func read(strings: [String]?, symbols: [String]?, sizes: [String]?, motion: [String]?, problems: inout [String]) -> Words {
        var words = Words.defaults
        var seen: Set<String> = []
        func once(_ field: String, _ key: String, _ line: String) -> Bool {
            guard seen.insert(field + " " + key).inserted else {
                problems.append("\(field) `\(line)`: `\(key)` is set twice")
                return false
            }
            return true
        }
        for line in strings ?? [] where !blank(line) {
            do {
                let (key, value) = try KeyLine.split(line, example: "library.title = Library")
                if WordTable.entry(key, in: WordTable.lists) != nil {
                    if once("strings", key, line) { words.lists[key] = try KeyLine.list(value) }
                } else if WordTable.entry(key, in: WordTable.strings) != nil {
                    if once("strings", key, line) { words.strings[key] = try KeyLine.text(value) }
                } else {
                    throw NotesError.line(line, "`\(key)` is not a string key; \(near(key, in: WordTable.strings + WordTable.lists))")
                }
            } catch { problems.append("strings \(error)") }
        }
        for line in symbols ?? [] where !blank(line) {
            do {
                let (key, value) = try KeyLine.split(line, example: "library.new = square.and.pencil")
                guard WordTable.entry(key, in: WordTable.symbols) != nil else {
                    throw NotesError.line(line, "`\(key)` is not a symbol key; \(near(key, in: WordTable.symbols))")
                }
                let name = try KeyLine.text(value)
                guard name.range(of: #"^[a-z0-9]+(\.[a-z0-9]+)*$"#, options: .regularExpression) != nil else {
                    throw NotesError.line(line, "`\(name)` is not an SF Symbol's name: lowercase words joined by dots, like `square.and.pencil`")
                }
                if once("symbols", key, line) { words.symbols[key] = name }
            } catch { problems.append("symbols \(error)") }
        }
        for line in sizes ?? [] where !blank(line) {
            do {
                let (key, value) = try KeyLine.split(line, example: "grid.minimum = 160")
                guard WordTable.entry(key, in: WordTable.sizes) != nil else {
                    throw NotesError.line(line, "`\(key)` is not a size key; \(near(key, in: WordTable.sizes))")
                }
                guard let number = Double(value), number.isFinite, number >= 0 else {
                    throw NotesError.line(line, "`\(value)` is not a size: a number of points, like `16`")
                }
                if WordTable.wholeSizes.contains(key), number.rounded() != number || number < 1 {
                    throw NotesError.line(line, "`\(key)` is a count: a whole number from 1, like `3`")
                }
                if WordTable.fractionSizes.contains(key), number <= 0 || number > 1 {
                    throw NotesError.line(line, "`\(key)` is a fraction of the screen: above 0 and at most 1, like `0.6`")
                }
                if once("sizes", key, line) { words.sizes[key] = literal(number) }
            } catch { problems.append("sizes \(error)") }
        }
        for line in motion ?? [] where !blank(line) {
            do {
                let (key, value) = try KeyLine.split(line, example: "library.filter = .bouncy")
                guard WordTable.entry(key, in: WordTable.motion) != nil else {
                    throw NotesError.line(line, "`\(key)` is not a motion key; \(near(key, in: WordTable.motion))")
                }
                if WordTable.seconds.contains(key) {
                    guard let number = Double(value), number.isFinite, number >= 0 else {
                        throw NotesError.line(line, "`\(key)` is a delay: seconds, like `0.6`")
                    }
                    if once("motion", key, line) { words.motion[key] = literal(number) }
                } else {
                    let written = value.hasPrefix("Animation.") ? String(value.dropFirst("Animation".count)) : value
                    guard isAnimation(written) else {
                        throw NotesError.line(line, "`\(value)` is not an animation: one of SwiftUI's, like `.bouncy`, `.smooth`, `.snappy`, `.easeInOut(duration: 0.3)` or `.spring(response: 0.4, dampingFraction: 0.8)`")
                    }
                    if once("motion", key, line) { words.motion[key] = written }
                }
            } catch { problems.append("motion \(error)") }
        }
        return words
    }

    /// `.bouncy`, `.spring(response: 0.4, dampingFraction: 0.8)`, `.easeInOut(duration: 0.3).delay(0.1)`.
    static func isAnimation(_ text: String) -> Bool {
        let base = #"\.(bouncy|smooth|snappy|default|linear|easeIn|easeOut|easeInOut|spring|interactiveSpring|interpolatingSpring)"#
        let arguments = #"(\(\s*([A-Za-z]+\s*:\s*-?[0-9]+(\.[0-9]+)?\s*(,\s*)?)*\))?"#
        let modifiers = #"(\.(speed|delay)\(\s*[0-9]+(\.[0-9]+)?\s*\))*"#
        return text.range(of: "^" + base + arguments + modifiers + "$", options: .regularExpression) != nil
    }

    /// A number as Swift writes it: `160`, `0.6`.
    static func literal(_ number: Double) -> String {
        if number.rounded() == number, abs(number) < 1e9 { return String(Int(number)) }
        return String(number)
    }

    private static func blank(_ line: String) -> Bool { line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// The keys that share the unknown key's first part, or all of them: what a refusal lists.
    private static func near(_ key: String, in table: [WordTable.Entry]) -> String {
        let head = key.split(separator: ".").first.map(String.init) ?? key
        let close = table.map(\.key).filter { $0.hasPrefix(head + ".") }
        let listed = close.isEmpty ? table.map(\.key) : close
        return "the keys\(close.isEmpty ? "" : " for \(head)") are " + listed.joined(separator: ", ")
    }
}
