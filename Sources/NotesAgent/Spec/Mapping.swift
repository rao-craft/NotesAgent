//  WHAT: One mapping line, read: which role an app's type takes, and how each thing the views show is read off it.

import Foundation

struct Mapping: Sendable, Equatable {
    /// How a right side reads its value.
    enum Source: Sendable, Equatable {
        /// A bare path, read off the value: `title`, `meta?.title`.
        case path(String)
        /// Swift that may name `value`: `value.title ?? "Untitled"`.
        case expression(String)
    }

    struct Assignment: Sendable, Equatable {
        let property: NoteProperty
        let source: Source
    }

    let line: String
    let role: NoteRole
    /// The app's type, as the line wrote it: `Note`, `SeerKit.Note`.
    let type: String
    /// How the type is identified, when the line says so (`id=slug`); nil when it has an `id` of its own.
    let id: Source?
    let assignments: [Assignment]

    /// The type's name for a file: `SeerKit.Note` is `SeerKitNote`.
    var fileStem: String { type.replacingOccurrences(of: ".", with: "") }

    func source(of key: String) -> Source? { assignments.first { $0.property.key == key }?.source }
}
