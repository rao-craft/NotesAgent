extension Template {
    static let notesCategoryButton = ##"""
import SwiftUI

/// One category in a picker: its name and a trailing mark (a ring, filled when it is the one chosen, or a chevron
/// while editing) in its colour, on the category gradient, outlined in its colour when chosen.
struct NotesCategoryButton: View {
    enum Mark { case select, edit }

    let category: NotesCategory
    var selected = false
    var mark: Mark = .select
    /// Drawn at 0.3 and answers a tap with an error feel (the general category while editing).
    var disabled = false
    let action: () -> Void

    var body: some View {
        Button {
            if disabled { NotesHaptics.error() } else { action() }
        } label: {
            HStack {
                Text(category.shownName)
                    .foregroundStyle(category.name.isEmpty ? .secondary : .primary)
                    .lineLimit(mark == .select ? 1 : 2)

                Spacer()

                Image(systemName: mark == .edit ? {{y:picker.edit}} : selected ? {{y:picker.on}} : {{y:picker.off}})
                    .foregroundStyle(category.color)
                    .bold()
                    .modifier(NotesShadow(kind: .subtle, color: .black.opacity(0.2)))
            }
            .contentShape(Rectangle())
            .contentTransition(.symbolEffect(.automatic))
        }
        .buttonStyle(NotesGradientButtonStyle(end: category.color))
        .overlay {
            if mark == .select {
                RoundedRectangle(cornerRadius: {{n:picker.radius}})
                    .stroke((selected ? category.color : Color.gray).gradient.opacity(selected ? 0.5 : 0.1), lineWidth: {{n:picker.stroke}})
            } else {
                RoundedRectangle(cornerRadius: {{n:picker.radius}})
                    .stroke(Color.gray.gradient.opacity(0.1), lineWidth: 3)
            }
        }
        .opacity(disabled ? 0.3 : 1)
        .accessibilityLabel(category.shownName)
    }
}

#Preview {
    VStack {
        NotesCategoryButton(category: NotesEntry.sampleCategories[1], selected: true) {}
        NotesCategoryButton(category: NotesEntry.sampleCategories[2]) {}
        NotesCategoryButton(category: NotesEntry.sampleCategories[0], mark: .edit, disabled: true) {}
    }
    .padding()
}
"""##
}
