//  WHAT: `NotesLook`, the one enum of the look the views read: each role the app's Swift for it (a `look` line) or the
//        system value the notes screens are drawn in. Computed members, so the kit holds no state of its own.

import Foundation

enum LookEmitter {
    static func emit(_ mapped: [String: String]) -> String {
        var lines = [
            "import SwiftUI",
            "",
            "/// The notes views' look: each role the app's own name for it, or the value the views are drawn in.",
            "enum NotesLook {",
        ]
        for (index, role) in LookRole.all.enumerated() {
            if index > 0 { lines.append("") }
            lines.append("    /// \(role.doc.prefix(1).uppercased() + role.doc.dropFirst()).")
            lines.append("    static var \(role.name): \(role.swiftType) { \(mapped[role.name] ?? role.fallback) }")
        }
        lines.append("}")
        return lines.joined(separator: "\n") + "\n"
    }
}
