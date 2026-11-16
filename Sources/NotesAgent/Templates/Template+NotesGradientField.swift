extension Template {
    static let notesGradientField = ##"""
import SwiftUI

/// A category's name field: padded, medium weight, on a gradient to the category's colour, rounded, with a soft
/// shadow and an outline of the colour.
struct NotesGradientField: ViewModifier {
    let start: Color
    let end: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .fontWeight(.medium)
            .background(
                LinearGradient(colors: [start, end.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(.rect(cornerRadius: {{n:picker.radius}}))
            .modifier(NotesShadow(kind: .soft, color: NotesLook.buttonShadow))
            .overlay {
                RoundedRectangle(cornerRadius: {{n:picker.radius}})
                    .stroke(end.gradient.opacity(0.5), lineWidth: {{n:picker.stroke}})
                    .allowsHitTesting(false)
            }
    }
}

#Preview {
    TextField("Name your category...", text: .constant(""))
        .modifier(NotesGradientField(start: NotesLook.card.opacity(0.8), end: Color.brown.opacity(0.8)))
        .padding()
}
"""##
}
