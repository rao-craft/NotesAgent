//  WHAT: The files that make an app's types the views' types: one extension a mapping line, each mapped property a
//        computed requirement that reads the type through `NotesValue` and, when the editor changes it, writes it back
//        through `NotesValue.assign`.
//  PIN:  AN UNMAPPED PROPERTY IS NOT WRITTEN: the protocol's default answers for it, so a conformance holds only what
//        the line says. An `id` the type already has is never redeclared.
//  PIN:  WHAT CANNOT BE WRITTEN BACK IS SAID: a right side that is Swift, a path through an optional, or a `let`
//        field is read and never written, and the answer names it.

import Foundation

enum ConformanceEmitter {
    struct File: Sendable, Equatable {
        let name: String
        let text: String
    }

    /// One file a mapping line, `<Type>+Note.swift` or `<Type>+NoteCategory.swift`, and a note for each property the
    /// editor shows but cannot write back. `writable` says, of a path on a type, whether every step to it is a `var`
    /// (nil when the app's types do not say).
    static func emit(_ mappings: [Mapping], imports: [String], writable: (String, String) -> Bool?) -> (files: [File], notes: [String]) {
        var files: [File] = [], notes: [String] = []
        for mapping in mappings {
            var body: [String] = []
            if let id = mapping.id {
                if mapping.role == .note {
                    // `Identifiable` is public, so a public type's `id` must be too; on an internal type it is internal.
                    body.append("    /// Identifies it to the views; public because `Identifiable` asks that of a public type.")
                    body += getter("id", type: "String", conversion: "text", source: id, access: "public ")
                } else {
                    body += getter(mapping.role.idMember, type: "String", conversion: "text", source: id)
                }
            }
            for assignment in mapping.assignments {
                let property = assignment.property
                if property.kind == .new {
                    guard case .expression(let swift) = assignment.source else { continue }
                    body.append("    /// A new, empty note the editor starts from.")
                    body.append("    static var \(property.member): \(mapping.type)? { \(swift) }")
                    continue
                }
                guard property.written else {
                    body += getter(property.member, type: property.kind.swiftType, conversion: property.kind.conversion, source: assignment.source)
                    continue
                }
                switch assignment.source {
                case .path(let path) where !path.contains("?") && writable(mapping.type, path) != false:
                    body += [
                        "    var \(property.member): \(property.kind.swiftType) {",
                        "        get { NotesValue.\(property.kind.conversion)(self.\(path)) }",
                        "        set { NotesValue.assign(newValue, to: &self.\(path)) }",
                        "    }",
                    ]
                default:
                    let why: String
                    switch assignment.source {
                    case .path(let path) where path.contains("?"): why = "`\(path)` reads through an optional"
                    case .path(let path): why = "`\(path)` is a `let`"
                    case .expression: why = "it is read through Swift"
                    }
                    notes.append("\(mapping.type)'s \(property.key) is shown and never written back, since \(why): the editor's changes to it stay in the view.")
                    body.append("    /// Read only: \(why), so the editor's changes to it stay in the view.")
                    body += readOnly(property.member, type: property.kind.swiftType, conversion: property.kind.conversion, source: assignment.source)
                }
            }
            var text = header(imports, swiftUI: mapping.role == .category)
            text += [
                "/// \(article(mapping.type).capitalized) `\(mapping.type)` as the notes views show \(mapping.role == .note ? "and edit it" : "a category").",
                "extension \(mapping.type): \(mapping.role.protocolName) {",
            ]
            text += body
            text.append("}")
            files.append(File(name: "\(mapping.fileStem)+\(mapping.role.name).swift", text: text.joined(separator: "\n") + "\n"))
        }
        return (files, notes)
    }

    // MARK: Lines

    private static func header(_ imports: [String], swiftUI: Bool) -> [String] {
        let modules = ["Foundation"] + (swiftUI ? ["SwiftUI"] : []) + imports.filter { $0 != "Foundation" && $0 != "SwiftUI" }
        return modules.map { "import \($0)" } + [""]
    }

    /// A computed requirement: a bare path read off the type, or an expression that names `value`.
    private static func getter(_ member: String, type: String, conversion: String, source: Mapping.Source, access: String = "") -> [String] {
        switch source {
        case .path(let path):
            return ["    \(access)var \(member): \(type) { NotesValue.\(conversion)(self.\(path)) }"]
        case .expression(let expression):
            guard namesValue(expression) else {
                return ["    \(access)var \(member): \(type) { NotesValue.\(conversion)(\(expression)) }"]
            }
            return [
                "    \(access)var \(member): \(type) {",
                "        let value = self",
                "        return NotesValue.\(conversion)(\(expression))",
                "    }",
            ]
        }
    }

    /// A requirement the editor may set that is only read: its setter keeps nothing.
    private static func readOnly(_ member: String, type: String, conversion: String, source: Mapping.Source) -> [String] {
        let read: [String]
        switch source {
        case .path(let path):
            read = ["        get { NotesValue.\(conversion)(self.\(path)) }"]
        case .expression(let expression):
            read = namesValue(expression)
                ? ["        get {", "            let value = self", "            return NotesValue.\(conversion)(\(expression))", "        }"]
                : ["        get { NotesValue.\(conversion)(\(expression)) }"]
        }
        return ["    var \(member): \(type) {"] + read + ["        set {}", "    }"]
    }

    private static func namesValue(_ expression: String) -> Bool {
        expression.range(of: #"(?<![A-Za-z0-9_.])value(?![A-Za-z0-9_])"#, options: .regularExpression) != nil
    }

    private static func article(_ word: String) -> String {
        guard let first = word.first?.lowercased() else { return "a" }
        return "aeiou".contains(first) ? "an" : "a"
    }
}
