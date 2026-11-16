extension Template {
    static let notesDismissButton = ##"""
import SwiftUI

/// A sheet's close button: a large `xmark`, with a light tap.
struct NotesDismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button({{s:sheet.dismiss}}, systemImage: {{y:sheet.dismiss}}) {
            NotesHaptics.light()
            dismiss()
        }
        .imageScale(.large)
        .labelStyle(.iconOnly)
    }
}

#Preview {
    NavigationStack {
        Text("Sheet")
            .toolbar {
                ToolbarItem(placement: NotesPlatform.trailing) {
                    NotesDismissButton()
                }
            }
    }
}
"""##
}
