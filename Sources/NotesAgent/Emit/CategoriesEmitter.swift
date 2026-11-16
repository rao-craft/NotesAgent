//  WHAT: `NotesCategories`, the categories the views start with, from the call's `categories` lines: the general one,
//        the memories (if any), the listed ones, and a new category's colour.

import Foundation

enum CategoriesEmitter {
    static func emit(_ spec: CategorySpec) -> String {
        func value(_ named: CategorySpec.Named) -> String {
            "NotesCategory(name: \(SwiftLiteral.string(named.name)), color: \(named.color ?? spec.unlisted))"
        }
        var lines = [
            "import SwiftUI",
            "",
            "/// The categories the notes views start with; the app's own come in beside them.",
            "enum NotesCategories {",
            "    /// Where a new note goes, and where a deleted category's notes move; never deleted.",
            "    static let general = \(value(spec.general))",
            "",
            "    /// The notes shown only under the memories button, on cards without a title; nil when there are none.",
            "    static let memory: NotesCategory? = \(spec.memory.map(value) ?? "nil")",
            "",
            "    /// The categories listed after the general one.",
        ]
        if spec.listed.isEmpty {
            lines.append("    static let listed: [NotesCategory] = []")
        } else {
            lines.append("    static let listed: [NotesCategory] = [")
            lines += spec.listed.map { "        \(value($0))," }
            lines.append("    ]")
        }
        lines += [
            "",
            "    /// A new category's colour, and that of a category a note names that none lists.",
            "    static var unlisted: Color { \(spec.unlisted) }",
            "}",
        ]
        return lines.joined(separator: "\n") + "\n"
    }
}
