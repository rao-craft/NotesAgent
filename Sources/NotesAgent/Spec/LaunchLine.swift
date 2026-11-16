//  WHAT: A `launch` line: a destination the app is launched into (`-destination <name>`) and the state the notes
//        views open in for it, written into `NotesLaunch`.
//
//            library = grid                   the grid
//            library.memories = memories      the grid of memories
//            library.categories = categories  the category sheet up over the grid
//            library.new = new                a new note's editor in its sheet
//            note = new "Launch windows" "Mars and Earth line up…\n\nPerseverance left…"
//                                             the same, its title and text already written and its title focused
//            note = editor space-001          a note's editor pushed: the note whose id, else whose title, it names
//
//  PIN:  THE APP'S NAVIGATION OPENS THE PAGE; the views open their own sheets and pushes for the state, as if the
//        person had gone there.

import Foundation

enum LaunchState: Sendable, Equatable {
    case grid, memories, categories, new
    /// A new note's editor in its sheet, its title and text already written.
    case draft(title: String, body: String)
    case editor(String)

    /// Swift for the state in `NotesLaunch.State`.
    var swift: String {
        switch self {
        case .grid: return ".grid"
        case .memories: return ".memories"
        case .categories: return ".categories"
        case .new: return ".new"
        case .draft(let title, let body): return ".draft(title: \(SwiftLiteral.string(title)), body: \(SwiftLiteral.string(body)))"
        case .editor(let target): return ".editor(\(SwiftLiteral.string(target)))"
        }
    }
}

enum LaunchLine {
    static let states = "grid, memories, categories, new (with a new note's title and text in quotes when it opens written: `new \"Launch windows\" \"Mars and Earth…\"`), or editor and a note's id or title (`editor space-001`)"

    static func parse(_ line: String) throws -> (name: String, state: LaunchState) {
        let (name, value) = try KeyLine.split(line, example: "note = editor space-001")
        guard name.range(of: #"^[A-Za-z0-9_]+([.-][A-Za-z0-9_]+)*$"#, options: .regularExpression) != nil else {
            throw NotesError.line(line, "`\(name)` is not a destination's name: letters, digits and `_`, in parts joined by `.` or `-`, like `note`")
        }
        let words = value.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        let head = words[0].lowercased()
        switch head {
        case "new" where words.count == 2:
            // A new note already written, as a screenshot shows it: its title, and its text when a second piece follows.
            let written = "`new` opens a new note, empty or written: its title and text each in quotes, like `new \"Launch windows\" \"Mars and Earth line up…\"`"
            guard let pieces = try quoted(words[1], line: line), (1...2).contains(pieces.count) else {
                throw NotesError.line(line, written)
            }
            return (name, .draft(title: pieces[0], body: pieces.count == 2 ? pieces[1] : ""))
        case "grid", "memories", "categories", "new":
            guard words.count == 1 else { throw NotesError.line(line, "`\(head)` takes nothing after it; a state is \(states)") }
            return (name, [.grid, .memories, .categories, .new][["grid", "memories", "categories", "new"].firstIndex(of: head)!])
        case "editor":
            guard words.count == 2 else { throw NotesError.line(line, "`editor` names the note it opens: `editor space-001` or `editor \"A note's title\"`") }
            var target = words[1].trimmingCharacters(in: .whitespaces)
            if target.hasPrefix("(") && target.hasSuffix(")") { target = String(target.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces) }
            let text = try KeyLine.text(target)
            guard !text.isEmpty else { throw NotesError.line(line, "`editor` names the note it opens: `editor space-001`") }
            return (name, .editor(text))
        default:
            throw NotesError.line(line, "`\(value)` is not a state; a state is \(states)")
        }
    }

    /// `"Launch windows" "Mars and Earth…"`: the text of each quoted piece in turn, with `\n`, `\"` and `\\` read and a
    /// line break kept as it is; nil when anything but space stands outside the quotes.
    static func quoted(_ text: String, line: String) throws -> [String]? {
        var pieces: [String] = [], current = "", inside = false, escaped = false
        for character in text {
            if inside {
                current.append(character)
                if escaped {
                    escaped = false
                } else if character == "\\" {
                    escaped = true
                } else if character == "\"" {
                    inside = false
                    pieces.append(try KeyLine.text(current))
                    current = ""
                }
            } else if character == "\"" {
                inside = true
                current = "\""
            } else if !character.isWhitespace {
                return nil
            }
        }
        if inside { throw NotesError.line(line, "the quote is not closed") }
        return pieces
    }
}
