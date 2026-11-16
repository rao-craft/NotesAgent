extension Template {
    static let notesMaterialButton = ##"""
import SwiftUI

/// A category sheet's floating button: its label in medium serif on thin material, rounded, with a large shadow and
/// an outline (stronger while what it stands for is chosen).
struct NotesMaterialButton: View {
    let title: String
    var selected = false
    /// A wide label (at least 200) rather than a fixed 100.
    var wide = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
        }
        .padding()
        .fontWeight(.medium)
        .fontDesign(.serif)
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: {{n:picker.radius}}))
        .modifier(NotesShadow(kind: .large, color: .black.opacity(0.3)))
        .overlay {
            RoundedRectangle(cornerRadius: {{n:picker.radius}})
                .stroke((selected ? Color.primary : Color.gray).gradient.opacity(selected ? 0.4 : 0.1), lineWidth: {{n:picker.stroke}})
        }
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var label: some View {
        if wide {
            Text(title)
                .foregroundStyle(Color.primary.gradient)
                .frame(minWidth: 200, maxHeight: 16)
        } else {
            Text(title)
                .foregroundStyle(Color.primary.gradient)
                .frame(width: 100, height: 16)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        NotesMaterialButton(title: "All notes", selected: true) {}
        NotesMaterialButton(title: "Create and assign new category", wide: true) {}
    }
    .padding()
}
"""##
}
