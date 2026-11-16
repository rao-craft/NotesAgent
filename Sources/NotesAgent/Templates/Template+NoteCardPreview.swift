extension Template {
    static let noteCardPreview = ##"""
import SwiftUI

/// A note as a long-press on its card previews it: its title in bold over a divider and up to seven lines of text.
struct NoteCardPreview: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title.isEmpty ? {{s:card.untitled}} : title)
                .lineLimit(2)
                .foregroundStyle(title.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .bold()

            Divider()

            Text(text.isEmpty ? {{s:card.noContent}} : text)
                .lineLimit(7)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .font(.caption)

            Spacer()
        }
        .frame(width: 300, height: 150)
        .padding()
    }
}

#Preview {
    NoteCardPreview(title: NotesEntry.samples[0].noteTitle, text: String(NotesEntry.samples[0].noteBody.characters))
}
"""##
}
