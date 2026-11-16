extension Template {
    static let notesCircleButton = ##"""
import SwiftUI

/// The round floating button that adds a category: a bold plus in the accent on a thin-material circle with a large
/// shadow and a faint ring.
struct NotesCircleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: {{y:picker.add}})
                .bold()
                .foregroundStyle(NotesLook.accent.gradient)
                .padding(5)
        }
        .buttonStyle(Style())
        .overlay {
            Circle()
                .stroke(Color.gray.gradient.opacity(0.1), lineWidth: {{n:picker.stroke}})
        }
        .accessibilityLabel({{s:picker.add}})
    }

    /// Padded, on thin material, round, with a large shadow; dimmed while pressed.
    private struct Style: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(.thinMaterial)
                .clipShape(Circle())
                .modifier(NotesShadow(kind: .large, color: .black.opacity(0.3)))
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}

#Preview {
    NotesCircleButton {}
        .padding()
}
"""##
}
