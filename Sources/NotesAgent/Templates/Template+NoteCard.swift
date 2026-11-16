extension Template {
    static let noteCard = ##"""
import SwiftUI

/// One note in the grid, leading-aligned in serif: its title, its date, its opening lines, a hairline, then its
/// category's dot and name, on a rounded card with a soft shadow.
struct NoteCard: View {
    let title: String
    let date: Date
    let text: String
    let category: NotesCategory
    /// Memories show no title.
    var showsTitle = true

    var body: some View {
        VStack(alignment: .leading) {
            if showsTitle {
                Text(title.isEmpty ? {{s:card.untitled}} : title)
                    .lineLimit(1)
                    .font(NotesLook.cardTitle)
                    .foregroundStyle(title.isEmpty ? .secondary : .primary)
            }

            VStack(alignment: .leading) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(NotesLook.cardDate)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 1)

                Text(text.isEmpty ? {{s:card.noContent}} : text)
                    .lineLimit({{n:card.lines}}, reservesSpace: true)
                    .font(NotesLook.cardText)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .font(.caption2)

            Divider()
                .padding(.vertical, 2)

            HStack(alignment: .center) {
                Circle()
                    .fill(category.color.gradient)
                    .frame(width: {{n:card.dot}}, height: {{n:card.dot}})
                Text(category.shownName)
                    .font(NotesLook.cardCategory)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                Spacer()
            }
        }
        .foregroundStyle(Color.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding({{n:card.padding}})
        .background(NotesLook.card)
        .clipShape(.rect(cornerRadius: {{n:card.radius}}))
        .overlay {
            RoundedRectangle(cornerRadius: {{n:card.radius}})
                .stroke(.black.gradient.opacity(0.4), lineWidth: {{n:card.border}})
        }
        .modifier(NotesShadow(kind: .soft, color: NotesLook.cardShadow))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let note = NotesEntry.samples[0]
    NoteCard(title: note.noteTitle, date: note.noteDate, text: String(note.noteBody.characters),
             category: NotesEntry.sampleCategories[1])
        .frame(width: 200, height: 160)
        .padding()
}
"""##
}
