extension Template {
    static let notesEmptyList = ##"""
import SwiftUI

/// The grid with no notes, centred: a large symbol, a bold title, a line picked when it appears and, when the app
/// makes notes, a button that starts one.
struct NotesEmptyList: View {
    /// Starts a note; without it the button is not drawn.
    var create: (() -> Void)?

    @State private var message = ""

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: {{y:library.empty}})
                .foregroundStyle(.secondary)
                .font(.system(size: {{n:empty.symbol}}))
                .padding(.bottom)

            NotesText.title({{s:library.emptyTitle}})
                .bold()
                .padding(.bottom, 3)

            NotesText.note2(message)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, {{n:empty.inset}})
                .padding(.bottom, 15)

            if let create {
                Button {
                    create()
                } label: {
                    NotesText.note2Action({{s:library.emptyAction}})
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if message.isEmpty {
                message = {{l:library.emptyMessages}}.randomElement() ?? ""
            }
        }
    }
}

#Preview {
    NotesEmptyList(create: {})
}
"""##
}
