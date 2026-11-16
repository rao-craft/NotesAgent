extension Template {
    static let noteCard = ##"""
import SwiftUI

/// One note in the grid, leading-aligned in serif: its title, its date and time on one line, cut off at the card's
/// edge (the time alone for today's), its opening lines, a hairline, then its category's dot and name, with a badge at
/// the end of that row for a memory or a note that lives only on the server; on a rounded card with a soft shadow.
struct NoteCard: View {
    let title: String
    let date: Date
    let text: String
    let category: NotesCategory
    /// Memories show no title.
    var showsTitle = true
    /// The badge of a memory or of a note that lives only on the server.
    var badged = false

    var body: some View {
        VStack(alignment: .leading) {
            if showsTitle {
                Text(title.isEmpty ? {{s:card.untitled}} : title)
                    .lineLimit(1)
                    .font(NotesLook.cardTitle)
                    .foregroundStyle(title.isEmpty ? .secondary : .primary)
            }

            VStack(alignment: .leading) {
                Text(date.formatted(date: Calendar.current.isDateInToday(date) ? .omitted : .abbreviated, time: .shortened))
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

                if badged {
                    Image(systemName: {{y:card.cloud}})
                        .font(.system(size: {{n:card.cloudSymbol}}, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding({{n:card.cloudPadding}})
                        .background(.ultraThinMaterial, in: Circle())
                        .accessibilityHidden(true)
                }
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
             category: NotesEntry.sampleCategories[1], badged: true)
        .frame(width: 200, height: 160)
        .padding()
}
"""##
}
