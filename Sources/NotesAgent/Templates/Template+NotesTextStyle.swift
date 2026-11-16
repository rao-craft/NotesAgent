extension Template {
    static let notesTextStyle = ##"""
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A style the formatting bar and the Format sheet toggle on the selection, or on what is typed next.
enum NotesTextStyle: String, CaseIterable, Identifiable, Sendable {
    case bold, italic, underlined, strikethrough

    var id: String { rawValue }

    /// Its name under its symbol in the Format sheet.
    var title: String {
        switch self {
        case .bold: return {{s:format.bold}}
        case .italic: return {{s:format.italic}}
        case .underlined: return {{s:format.underline}}
        case .strikethrough: return {{s:format.strikethrough}}
        }
    }

    var symbol: String {
        switch self {
        case .bold: return {{y:format.bold}}
        case .italic: return {{y:format.italic}}
        case .underlined: return {{y:format.underline}}
        case .strikethrough: return {{y:format.strikethrough}}
        }
    }
}

/// A paragraph's alignment, as the segmented pickers of the bar and the Format sheet set it.
enum NotesAlignment: String, CaseIterable, Identifiable, Sendable {
    case left, center, right, justified

    var id: String { rawValue }

    var title: String {
        switch self {
        case .left: return {{s:format.left}}
        case .center: return {{s:format.center}}
        case .right: return {{s:format.right}}
        case .justified: return {{s:format.justified}}
        }
    }

    var symbol: String {
        switch self {
        case .left: return {{y:format.left}}
        case .center: return {{y:format.center}}
        case .right: return {{y:format.right}}
        case .justified: return {{y:format.justified}}
        }
    }

    /// The text system's alignment.
    var platform: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return .justified
        }
    }

    /// The alignment a paragraph has; a natural one reads as left.
    init(_ alignment: NSTextAlignment) {
        switch alignment {
        case .center: self = .center
        case .right: self = .right
        case .justified: self = .justified
        default: self = .left
        }
    }
}
"""##
}
