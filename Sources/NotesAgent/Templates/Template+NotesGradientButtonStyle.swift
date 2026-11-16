extension Template {
    static let notesGradientButtonStyle = ##"""
import SwiftUI

/// A category's button: padded, medium weight, on a gradient from the card colour to the category's, outlined in a
/// hairline, rounded, with a soft shadow; dimmed while pressed.
struct NotesGradientButtonStyle: ButtonStyle {
    var start: Color = NotesLook.card
    let end: Color
    var startOpacity = 0.8
    var endOpacity = 0.5

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .fontWeight(.medium)
            .background(
                LinearGradient(
                    colors: [start.opacity(startOpacity), end.opacity(endOpacity)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    RoundedRectangle(cornerRadius: {{n:picker.radius}})
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
            )
            .clipShape(.rect(cornerRadius: {{n:picker.radius}}))
            .modifier(NotesShadow(kind: .soft, color: NotesLook.buttonShadow))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview {
    Button("Space") {}
        .buttonStyle(NotesGradientButtonStyle(end: .brown))
        .padding()
}
"""##
}
