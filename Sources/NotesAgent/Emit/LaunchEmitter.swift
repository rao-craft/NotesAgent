//  WHAT: `NotesLaunch`, the state the views open in when the app is launched with `-destination <name>`: the
//        `destination` default (where a launch argument lands) read against the call's `launch` lines.

import Foundation

enum LaunchEmitter {
    static func emit(_ states: [(name: String, state: LaunchState)]) -> String {
        var lines = [
            "import Foundation",
            "",
            "/// The state the notes views open in when the app is launched with `-destination <name>`, as if the person",
            "/// had gone there: the grid, its memories, the category sheet, a new note (empty or written), or a note's editor",
            "/// pushed.",
            "enum NotesLaunch {",
            "    enum State: Equatable {",
            "        case grid, memories, categories, new",
            "        /// A new note's editor, its title and text already written and its title focused.",
            "        case draft(title: String, body: String)",
            "        /// A note's editor: the note whose id, else whose title, this is.",
            "        case editor(String)",
            "    }",
            "",
            "    /// The state the launch names; nil when it names none of the notes views' states.",
            "    static var current: State? {",
        ]
        if states.isEmpty {
            lines.append("        nil")
        } else {
            lines.append("        switch UserDefaults.standard.string(forKey: \"destination\") {")
            for (name, state) in states {
                lines.append("        case \(SwiftLiteral.string(name)): return \(state.swift)")
            }
            lines.append("        default: return nil")
            lines.append("        }")
        }
        lines += ["    }", "}"]
        return lines.joined(separator: "\n") + "\n"
    }
}
