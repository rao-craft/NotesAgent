extension Template {
    static let notesProtocols = ##"""
import SwiftUI

/// A note as the notes views show and edit it: its title, its text, the category it is filed in and its date. The
/// app's own note type conforms in `Conformances/`, written from a mapping line; a property a line leaves out shows
/// its default here and keeps nothing the editor writes.
protocol NoteRepresentable: Identifiable {
    /// The note's title, empty when it has none.
    var noteTitle: String { get set }
    /// The note's text, with its formatting when the app keeps it.
    var noteBody: AttributedString { get set }
    /// The id (or the name) of the category the note is filed in; empty for the general one.
    var noteCategory: String { get set }
    /// When the note was written; the grid shows the newest first.
    var noteDate: Date { get set }
    /// A new, empty note the editor starts from; nil when no control makes a note.
    static var notesNew: Self? { get }
}

extension NoteRepresentable {
    var noteTitle: String {
        get { "" }
        set {}
    }

    var noteBody: AttributedString {
        get { AttributedString() }
        set {}
    }

    var noteCategory: String {
        get { "" }
        set {}
    }

    var noteDate: Date {
        get { .distantPast }
        set {}
    }

    static var notesNew: Self? { nil }
}

/// A category as the notes views show it: an id, a name and a colour. The app's own category type conforms in
/// `Conformances/`, written from a mapping line.
protocol NoteCategoryRepresentable {
    /// What a note's `noteCategory` names it by; its name when the line maps no id.
    var noteCategoryID: String { get }
    /// The name the picker and the cards show.
    var noteCategoryName: String { get }
    /// The dot on a card and the tint of its button.
    var noteCategoryColor: Color { get }
}

extension NoteCategoryRepresentable {
    var noteCategoryID: String { noteCategoryName }
    var noteCategoryColor: Color { NotesCategories.unlisted }
}
"""##
}
