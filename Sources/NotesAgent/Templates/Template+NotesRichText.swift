extension Template {
    static let notesRichText = ##"""
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// What a note's text view draws with, on the iPhone and the Mac: the body face and the label colour where the note
/// sets none, the styles, size, alignment and colours of a run, and the note's `AttributedString` as the view's text
/// and back.
enum NotesRichText {
    #if os(macOS)
    typealias Font = NSFont
    typealias Color = NSColor
    #else
    typealias Font = UIFont
    typealias Color = UIColor
    #endif

    typealias Attributes = [NSAttributedString.Key: Any]

    /// The face of a note's text where it sets none: the system body.
    static var body: Font {
        #if os(macOS)
        return NSFont.preferredFont(forTextStyle: .body, options: [:])
        #else
        return UIFont.preferredFont(forTextStyle: .body)
        #endif
    }

    /// The colour of a note's text where it sets none: the label colour.
    static var label: Color {
        #if os(macOS)
        return .labelColor
        #else
        return .label
        #endif
    }

    /// What is typed into a note that sets nothing.
    static var typing: Attributes { [.font: body, .foregroundColor: label] }

    // MARK: Reading a run

    static func font(in attributes: Attributes) -> Font {
        attributes[.font] as? Font ?? body
    }

    static func styles(in attributes: Attributes) -> Set<NotesTextStyle> {
        var styles = Set<NotesTextStyle>()
        let traits = font(in: attributes).fontDescriptor.symbolicTraits
        #if os(macOS)
        if traits.contains(.bold) { styles.insert(.bold) }
        if traits.contains(.italic) { styles.insert(.italic) }
        #else
        if traits.contains(.traitBold) { styles.insert(.bold) }
        if traits.contains(.traitItalic) { styles.insert(.italic) }
        #endif
        if (attributes[.underlineStyle] as? Int ?? 0) != 0 { styles.insert(.underlined) }
        if (attributes[.strikethroughStyle] as? Int ?? 0) != 0 { styles.insert(.strikethrough) }
        return styles
    }

    static func alignment(in attributes: Attributes) -> NotesAlignment {
        NotesAlignment((attributes[.paragraphStyle] as? NSParagraphStyle)?.alignment ?? .natural)
    }

    /// A run's colour as SwiftUI draws it; nil when the run sets none.
    static func color(_ value: Any?) -> SwiftUI.Color? {
        guard let color = value as? Color else { return nil }
        #if os(macOS)
        return SwiftUI.Color(nsColor: color)
        #else
        return SwiftUI.Color(uiColor: color)
        #endif
    }

    // MARK: Changing a run

    static func set(_ style: NotesTextStyle, _ on: Bool, in attributes: inout Attributes) {
        switch style {
        case .bold, .italic:
            let current = font(in: attributes)
            var traits = current.fontDescriptor.symbolicTraits
            #if os(macOS)
            let trait: NSFontDescriptor.SymbolicTraits = style == .bold ? .bold : .italic
            #else
            let trait: UIFontDescriptor.SymbolicTraits = style == .bold ? .traitBold : .traitItalic
            #endif
            if on { traits.insert(trait) } else { traits.remove(trait) }
            attributes[.font] = font(current, traits: traits)
        case .underlined:
            attributes[.underlineStyle] = on ? NSUnderlineStyle.single.rawValue : 0
        case .strikethrough:
            attributes[.strikethroughStyle] = on ? NSUnderlineStyle.single.rawValue : 0
        }
    }

    static func resize(_ attributes: inout Attributes, to size: Double) {
        let current = font(in: attributes)
        #if os(macOS)
        attributes[.font] = NSFont(descriptor: current.fontDescriptor, size: CGFloat(size)) ?? current
        #else
        attributes[.font] = current.withSize(CGFloat(size))
        #endif
    }

    static func align(_ attributes: inout Attributes, _ alignment: NotesAlignment) {
        let style = NSMutableParagraphStyle()
        if let current = attributes[.paragraphStyle] as? NSParagraphStyle {
            style.setParagraphStyle(current)
        }
        style.alignment = alignment.platform
        attributes[.paragraphStyle] = style
    }

    static func paint(_ attributes: inout Attributes, _ key: NSAttributedString.Key, _ color: SwiftUI.Color) {
        attributes[key] = Color(color)
    }

    #if os(macOS)
    private static func font(_ font: NSFont, traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        NSFont(descriptor: font.fontDescriptor.withSymbolicTraits(traits), size: font.pointSize) ?? font
    }
    #else
    private static func font(_ font: UIFont, traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return font }
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }
    #endif

    // MARK: The note's text and the view's

    /// The note's text as its view shows it: the body face and the label colour wherever the note sets none.
    static func shown(_ text: AttributedString) -> NSAttributedString {
        #if os(macOS)
        let converted = (try? NSAttributedString(text, including: \.appKit)) ?? NSAttributedString(string: String(text.characters))
        #else
        let converted = (try? NSAttributedString(text, including: \.uiKit)) ?? NSAttributedString(string: String(text.characters))
        #endif
        let result = NSMutableAttributedString(attributedString: converted)
        let whole = NSRange(location: 0, length: result.length)
        let face = Self.body, ink = Self.label
        result.enumerateAttribute(.font, in: whole) { value, range, _ in
            if value == nil { result.addAttribute(.font, value: face, range: range) }
        }
        result.enumerateAttribute(.foregroundColor, in: whole) { value, range, _ in
            if value == nil { result.addAttribute(.foregroundColor, value: ink, range: range) }
        }
        return result
    }

    /// The view's text as the note keeps it.
    static func kept(_ text: NSAttributedString) -> AttributedString {
        #if os(macOS)
        return (try? AttributedString(text, including: \.appKit)) ?? AttributedString(text.string)
        #else
        return (try? AttributedString(text, including: \.uiKit)) ?? AttributedString(text.string)
        #endif
    }
}
"""##
}
