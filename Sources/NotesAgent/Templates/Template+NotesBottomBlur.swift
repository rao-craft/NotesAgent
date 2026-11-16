extension Template {
    static let notesBottomBlur = ##"""
import SwiftUI

/// The bottom of a category sheet, blurred under its floating button and clear toward the top.
struct NotesBottomBlur: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .mask {
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
            .frame(height: 120)
            .allowsHitTesting(false)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.brown.opacity(0.3)
        NotesBottomBlur()
    }
}
"""##
}
