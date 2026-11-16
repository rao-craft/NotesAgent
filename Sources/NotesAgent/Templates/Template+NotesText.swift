extension Template {
    static let notesText = ##"""
import SwiftUI

/// The text roles the notes screens are drawn in: `title`, `note` and `note2`, each in its colour, and an action in
/// `note2` in the accent.
@MainActor
enum NotesText {
    static func title(_ text: String) -> Text {
        Text(text)
            .foregroundStyle(NotesLook.titleColor)
            .font(NotesLook.title)
    }

    static func note(_ text: String) -> Text {
        Text(text)
            .foregroundStyle(NotesLook.noteColor)
            .font(NotesLook.note)
    }

    static func note2(_ text: String) -> Text {
        Text(text)
            .foregroundStyle(NotesLook.noteColor)
            .font(NotesLook.note2)
    }

    static func note2Action(_ text: String) -> Text {
        Text(text)
            .foregroundStyle(NotesLook.accent)
            .font(NotesLook.note2)
    }
}

/// A screen's name inline in the bar, in `title`: the grid's, and each sheet's.
struct NotesInlineTitle: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NotesText.title(title)
                }
            }
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: 16) {
            NotesText.title("This looks a little empty...").bold()
            NotesText.note("Start writing and assign a category!").italic()
            NotesText.note2("What's on your mind?").italic()
            NotesText.note2Action("Create a note!")
        }
        .modifier(NotesInlineTitle(title: "Notes"))
    }
}
"""##
}
