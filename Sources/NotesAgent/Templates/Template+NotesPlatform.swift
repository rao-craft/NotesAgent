extension Template {
    static let notesPlatform = ##"""
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// What differs between the iPhone and the Mac, in one place: colours that follow the appearance, where a bar item
/// goes, the grouped fill.
enum NotesPlatform {
    /// A colour for light and one for dark.
    static func dynamic(light: Color, dark: Color) -> Color {
        #if os(macOS)
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        })
        #else
        return Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #endif
    }

    /// The fill of a row in a grouped form.
    static var groupedFill: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemGroupedBackground)
        #endif
    }

    /// The bar's leading side.
    @MainActor static var leading: ToolbarItemPlacement {
        #if os(macOS)
        return .navigation
        #else
        return .topBarLeading
        #endif
    }

    /// The bar's trailing side.
    @MainActor static var trailing: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .topBarTrailing
        #endif
    }
}

/// The feel a tap answers with: light on a tap that acts, soft on a choice, success on a save.
@MainActor
enum NotesHaptics {
    static func light() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func soft() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func error() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}
"""##
}
