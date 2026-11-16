extension Template {
    static let notesNoResults = ##"""
import SwiftUI

/// A filter with no notes, centred: a large symbol, a bold title and an italic line.
struct NotesNoResults: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: {{y:library.filteredEmpty}})
                .foregroundStyle(.secondary)
                .font(.system(size: {{n:empty.symbol}}))
                .padding(.bottom)

            NotesText.title({{s:library.filteredTitle}})
                .bold()
                .padding(.bottom, 3)

            NotesText.note({{s:library.filteredMessage}})
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, {{n:empty.inset}})
                .padding(.bottom, 15)
        }
    }
}

#Preview {
    NotesNoResults()
}
"""##
}
