//  WHAT: The roles an app's types take in the notes views, and what each shows: a note (its title, its body, its
//        category, its date, whether it lives only on the server, and how a new one is made) and a category (its id,
//        name and colour).

import Foundation

enum NoteRole: String, Sendable, CaseIterable {
    case note, category

    /// The words a line may start with for this role.
    var aliases: [String] {
        switch self {
        case .note: return ["entry", "page"]
        case .category: return ["folder", "group"]
        }
    }

    static func named(_ word: String) -> NoteRole? {
        let lower = word.lowercased()
        return allCases.first { $0.rawValue == lower || $0.aliases.contains(lower) }
    }

    /// The protocol a type of this role conforms to.
    var protocolName: String {
        switch self {
        case .note: return "NoteRepresentable"
        case .category: return "NoteCategoryRepresentable"
        }
    }

    /// The role's name in a file's name: `Note+Note.swift`, `Folder+NoteCategory.swift`.
    var name: String {
        switch self {
        case .note: return "Note"
        case .category: return "NoteCategory"
        }
    }

    /// The member that identifies a value of this role when the line says `id=`.
    var idMember: String {
        switch self {
        case .note: return "id"
        case .category: return "noteCategoryID"
        }
    }

    var properties: [NoteProperty] {
        switch self {
        case .note:
            return [
                NoteProperty("title", "noteTitle", .text, written: true, aliases: ["name", "heading"], doc: "The note's title, empty when it has none."),
                NoteProperty("body", "noteBody", .rich, written: true, aliases: ["text", "content"], doc: "The note's text, with its formatting when the field keeps it."),
                NoteProperty("category", "noteCategory", .text, written: true, aliases: ["folder", "tag"], doc: "The id of the category the note is filed in, empty for the general one."),
                NoteProperty("date", "noteDate", .date, written: true, aliases: ["created", "createdAt", "updated", "modified"], doc: "When the note was written; the grid shows the newest first."),
                NoteProperty("cloud", "noteCloudOnly", .flag, aliases: ["cloudOnly", "server", "remote"], doc: "Whether the note lives only on the app's server: its card wears the badge."),
                NoteProperty("new", "notesNew", .new, aliases: ["make", "empty"], doc: "A new, empty note the editor starts from; without it no control makes a note."),
            ]
        case .category:
            return [
                NoteProperty("name", "noteCategoryName", .text, aliases: ["title"], doc: "The category's name, as the picker and the cards show it."),
                NoteProperty("color", "noteCategoryColor", .color, aliases: ["colour", "tint"], doc: "The category's colour: the dot on a card and the tint of its button."),
            ]
        }
    }

    func property(named word: String) -> NoteProperty? {
        let lower = word.lowercased()
        return properties.first { $0.key.lowercased() == lower || $0.aliases.contains { $0.lowercased() == lower } }
    }
}
