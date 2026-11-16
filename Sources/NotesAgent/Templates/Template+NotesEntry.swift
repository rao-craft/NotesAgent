extension Template {
    static let notesEntry = ##"""
import SwiftUI

/// A note as a value: for an app with no note type of its own, and for the previews.
struct NotesEntry: NoteRepresentable, Hashable, Sendable {
    var id: String
    var noteTitle: String
    var noteBody: AttributedString
    var noteCategory: String
    var noteDate: Date

    init(id: String = UUID().uuidString, title: String = "", body: String = "", category: String = "", date: Date = Date()) {
        self.id = id
        self.noteTitle = title
        self.noteBody = AttributedString(body)
        self.noteCategory = category
        self.noteDate = date
    }

    static var notesNew: NotesEntry? { NotesEntry() }

    /// Notes to preview the views with.
    static let samples: [NotesEntry] = [
        NotesEntry(id: "sample-1", title: "Meeting Notes", body: "Discussed the new feature roadmap and assigned tasks to team members.",
                   category: "Work", date: Date(timeIntervalSince1970: 1_762_905_600)),
        NotesEntry(id: "sample-2", title: "Groceries", body: "Flour, eggs, butter, a lemon and something green.",
                   category: "Home", date: Date(timeIntervalSince1970: 1_762_819_200)),
        NotesEntry(id: "sample-3", title: "", body: "",
                   category: "", date: Date(timeIntervalSince1970: 1_762_732_800)),
        NotesEntry(id: "sample-4", title: "Reading", body: "The second chapter argues that habits are made in the small hours, one choice at a time.",
                   category: "Work", date: Date(timeIntervalSince1970: 1_762_646_400)),
    ]

    /// Categories to preview the views with.
    static let sampleCategories: [NotesCategory] = [
        NotesCategories.general,
        NotesCategory(name: "Work", color: .brown),
        NotesCategory(name: "Home", color: .teal),
    ]
}
"""##
}
