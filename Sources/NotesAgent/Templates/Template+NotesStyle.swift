extension Template {
    static let notesStyle = ##"""
import SwiftUI

/// The shadows the notes screens use: soft (radius 2, y 4) under cards and gradient buttons, subtle (radius 2, y 2)
/// under a category's mark, large (radius 8, y 4) under floating buttons.
struct NotesShadow: ViewModifier {
    enum Kind { case soft, subtle, large }

    let kind: Kind
    let color: Color

    func body(content: Content) -> some View {
        switch kind {
        case .soft: content.shadow(color: color, radius: 2, x: 0, y: 4)
        case .subtle: content.shadow(color: color, radius: 2, x: 0, y: 2)
        case .large: content.shadow(color: color, radius: 8, x: 0, y: 4)
        }
    }
}

/// A rounded shape of Liquid Glass where the system has it, and of regular material where it does not.
struct NotesGlass: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(in: RoundedRectangle(cornerRadius: radius))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: radius))
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("Soft")
            .padding()
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .modifier(NotesShadow(kind: .soft, color: NotesLook.cardShadow))
        Text("Glass")
            .padding()
            .modifier(NotesGlass(radius: 24))
    }
    .padding()
}
"""##
}
