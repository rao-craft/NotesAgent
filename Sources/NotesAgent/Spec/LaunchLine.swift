//  WHAT: A `launch` line: a destination the app is launched into (`-destination <name>`) and the state the notes
//        views open in for it, written into `NotesLaunch`.
//
//            library = grid                   the grid
//            library.memories = memories      the grid of memories
//            library.categories = categories  the category sheet up over the grid
//            library.new = new                a new note's editor in its sheet
//            note = editor space-001          a note's editor pushed: the note whose id, else whose title, it names
//
//  PIN:  THE APP'S NAVIGATION OPENS THE PAGE; the views open their own sheets and pushes for the state, as if the
//        person had gone there.

import Foundation

enum LaunchState: Sendable, Equatable {
    case grid, memories, categories, new
    case editor(String)

    /// Swift for the state in `NotesLaunch.State`.
    var swift: String {
        switch self {
        case .grid: return ".grid"
        case .memories: return ".memories"
        case .categories: return ".categories"
        case .new: return ".new"
        case .editor(let target): return ".editor(\(SwiftLiteral.string(target)))"
        }
    }
}

enum LaunchLine {
    static let states = "grid, memories, categories, new, or editor and a note's id or title (`editor space-001`)"

    static func parse(_ line: String) throws -> (name: String, state: LaunchState) {
        let (name, value) = try KeyLine.split(line, example: "note = editor space-001")
        guard name.range(of: #"^[A-Za-z0-9_]+([.-][A-Za-z0-9_]+)*$"#, options: .regularExpression) != nil else {
            throw NotesError.line(line, "`\(name)` is not a destination's name: letters, digits and `_`, in parts joined by `.` or `-`, like `note`")
        }
        let words = value.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        let head = words[0].lowercased()
        switch head {
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
}
