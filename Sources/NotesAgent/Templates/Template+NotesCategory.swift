extension Template {
    static let notesCategory = ##"""
import SwiftUI

/// A category as the notes views keep it: an id, a name and a colour.
struct NotesCategory: Identifiable, Hashable, Sendable {
    /// What a note's `noteCategory` names it by.
    var id: String
    var name: String
    var color: Color

    init(id: String? = nil, name: String, color: Color) {
        self.id = id ?? name
        self.name = name
        self.color = color
    }

    init(_ category: any NoteCategoryRepresentable) {
        self.init(id: category.noteCategoryID, name: category.noteCategoryName, color: category.noteCategoryColor)
    }

    /// The name as the views show it.
    var shownName: String { name.isEmpty ? {{s:category.unnamed}} : name }

    /// Whether a note's `noteCategory` names this one: by its id, or by its name in any case.
    func holds(_ key: String) -> Bool {
        id == key || name.compare(key, options: .caseInsensitive) == .orderedSame
    }

    /// The category a note's `noteCategory` names among `shelf`: the general one for none, the memories, a listed
    /// one, or one made for the name, in the unlisted colour.
    static func resolve(_ key: String, in shelf: [NotesCategory]) -> NotesCategory {
        if key.isEmpty { return NotesCategories.general }
        if let memory = NotesCategories.memory, memory.holds(key) { return memory }
        return shelf.first { $0.holds(key) } ?? NotesCategory(id: key, name: key, color: NotesCategories.unlisted)
    }
}
"""##
}
