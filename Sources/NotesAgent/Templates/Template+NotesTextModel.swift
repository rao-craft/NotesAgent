extension Template {
    static let notesTextModel = ##"""
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A note's text view as the formatting bar and the Format sheet read and change it: whether it is being edited, what
/// can be undone, and the styles, size, alignment and colours of the selection, or of what is typed next. Setting
/// the size, the alignment or a colour changes the text.
@MainActor
final class NotesTextModel: ObservableObject {
    /// Whether the text is being edited: the formatting bar shows only then.
    @Published var isEditing = false
    @Published private(set) var canUndo = false
    @Published private(set) var canRedo = false
    @Published private(set) var styles: Set<NotesTextStyle> = []

    @Published var fontSize: Double = 17 {
        didSet {
            if !reading, fontSize != oldValue { change { NotesRichText.resize(&$0, to: fontSize) } }
        }
    }

    @Published var alignment: NotesAlignment = .left {
        didSet {
            if !reading, alignment != oldValue { change { NotesRichText.align(&$0, alignment) } }
        }
    }

    @Published var textColor: Color = .primary {
        didSet {
            if !reading { change { NotesRichText.paint(&$0, .foregroundColor, textColor) } }
        }
    }

    @Published var highlightColor: Color = .clear {
        didSet {
            if !reading { change { NotesRichText.paint(&$0, .backgroundColor, highlightColor) } }
        }
    }

    /// Whether a style, size, alignment or colour changed since the editor opened.
    private(set) var restyled = false

    #if os(macOS)
    /// The text view, set as it is made.
    weak var view: NSTextView?
    #else
    /// The text view, set as it is made.
    weak var view: UITextView?
    #endif

    /// Hands the text view's text to the note after a change made here.
    var changed: (@MainActor (NSAttributedString) -> Void)?

    private var reading = false

    /// A model for a text view not yet made; `editing` shows the bar before the view is (in a preview).
    init(editing: Bool = false) {
        isEditing = editing
    }

    // MARK: What the bar and the sheet do

    func undo() {
        view?.undoManager?.undo()
        report()
    }

    func redo() {
        view?.undoManager?.redo()
        report()
    }

    func toggle(_ style: NotesTextStyle) {
        let on = !styles.contains(style)
        change { NotesRichText.set(style, on, in: &$0) }
    }

    /// A step of the size; never under the least.
    func step(_ points: Double) {
        fontSize = max({{n:format.minimum}}, fontSize + points)
    }

    func beginEditing() {
        #if os(macOS)
        _ = view?.window?.makeFirstResponder(view)
        #else
        _ = view?.becomeFirstResponder()
        #endif
    }

    /// Drops the keyboard.
    func endEditing() {
        #if os(macOS)
        _ = view?.window?.makeFirstResponder(nil)
        #else
        _ = view?.resignFirstResponder()
        #endif
    }

    // MARK: The text view

    /// Hands the text on, and reads the selection back into the bar and the sheet.
    func report() {
        guard let view else { return }
        #if os(macOS)
        changed?(view.attributedString())
        #else
        changed?(view.attributedText ?? NSAttributedString())
        #endif
        read()
    }

    /// Reads the attributes of the selection, or of what is typed next.
    func read() {
        guard let view else { return }
        let attributes = view.typingAttributes
        reading = true
        defer { reading = false }
        let size = Double(NotesRichText.font(in: attributes).pointSize)
        if fontSize != size { fontSize = size }
        let styles = NotesRichText.styles(in: attributes)
        if self.styles != styles { self.styles = styles }
        let alignment = NotesRichText.alignment(in: attributes)
        if self.alignment != alignment { self.alignment = alignment }
        if let color = NotesRichText.color(attributes[.foregroundColor]), color != textColor { textColor = color }
        if let color = NotesRichText.color(attributes[.backgroundColor]), color != highlightColor { highlightColor = color }
        let canUndo = view.undoManager?.canUndo ?? false
        if self.canUndo != canUndo { self.canUndo = canUndo }
        let canRedo = view.undoManager?.canRedo ?? false
        if self.canRedo != canRedo { self.canRedo = canRedo }
    }

    /// Changes what is typed next and, with a selection, the selected text; then hands the text on.
    private func change(_ body: (inout NotesRichText.Attributes) -> Void) {
        guard let view else { return }
        var attributes = view.typingAttributes
        body(&attributes)
        let range = view.selectedRange
        if range.length > 0 {
            #if os(macOS)
            view.textStorage?.addAttributes(attributes, range: range)
            #else
            view.textStorage.addAttributes(attributes, range: range)
            #endif
        }
        view.typingAttributes = attributes
        restyled = true
        report()
    }
}
"""##
}
