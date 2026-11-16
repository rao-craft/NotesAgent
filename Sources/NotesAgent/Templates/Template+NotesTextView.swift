extension Template {
    static let notesTextView = ##"""
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A note's text, editable and attributed: a text view in the body face and the label colour on a clear ground,
/// inset on every side, whose selection, editing and undo the model follows.
#if os(macOS)
struct NotesTextView: NSViewRepresentable {
    @Binding var text: AttributedString
    let model: NotesTextModel

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, model: model)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        scroll.drawsBackground = false
        scroll.hasHorizontalScroller = false
        guard let view = scroll.documentView as? NSTextView else { return scroll }
        view.isRichText = true
        view.allowsUndo = true
        view.drawsBackground = false
        view.textContainerInset = NSSize(width: {{n:editor.textInset}}, height: {{n:editor.textInset}})
        view.textStorage?.setAttributedString(NotesRichText.shown(text))
        view.typingAttributes = NotesRichText.typing
        view.delegate = context.coordinator
        model.view = view
        model.changed = { [weak coordinator = context.coordinator] in coordinator?.take($0) }
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        let coordinator = context.coordinator
        coordinator.text = $text
        guard let view = scroll.documentView as? NSTextView, text != coordinator.shown else { return }
        coordinator.shown = text
        coordinator.applying = true
        view.textStorage?.setAttributedString(NotesRichText.shown(text))
        coordinator.applying = false
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<AttributedString>
        let model: NotesTextModel
        /// The text last shown or handed on, to tell the note's changes from the view's.
        var shown: AttributedString
        /// Set while the note's text is put in the view.
        var applying = false

        init(text: Binding<AttributedString>, model: NotesTextModel) {
            self.text = text
            self.model = model
            self.shown = text.wrappedValue
        }

        /// Hands the view's text to the note.
        func take(_ value: NSAttributedString) {
            let kept = NotesRichText.kept(value)
            shown = kept
            text.wrappedValue = kept
        }

        func textDidBeginEditing(_ notification: Notification) {
            guard !applying else { return }
            model.isEditing = true
            model.read()
        }

        func textDidChange(_ notification: Notification) {
            guard !applying, let view = notification.object as? NSTextView else { return }
            take(view.attributedString())
            model.read()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard !applying else { return }
            model.read()
        }

        func textDidEndEditing(_ notification: Notification) {
            guard !applying else { return }
            model.isEditing = false
            model.read()
        }
    }
}
#else
struct NotesTextView: UIViewRepresentable {
    @Binding var text: AttributedString
    let model: NotesTextModel

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, model: model)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.font = NotesRichText.body
        view.textColor = NotesRichText.label
        view.allowsEditingTextAttributes = true
        view.textContainerInset = UIEdgeInsets(top: {{n:editor.textInset}}, left: {{n:editor.textInset}},
                                               bottom: {{n:editor.textInset}}, right: {{n:editor.textInset}})
        view.attributedText = NotesRichText.shown(text)
        view.typingAttributes = NotesRichText.typing
        view.delegate = context.coordinator
        model.view = view
        model.changed = { [weak coordinator = context.coordinator] in coordinator?.take($0) }
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.text = $text
        guard text != coordinator.shown else { return }
        coordinator.shown = text
        coordinator.applying = true
        view.attributedText = NotesRichText.shown(text)
        coordinator.applying = false
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<AttributedString>
        let model: NotesTextModel
        /// The text last shown or handed on, to tell the note's changes from the view's.
        var shown: AttributedString
        /// Set while the note's text is put in the view.
        var applying = false

        init(text: Binding<AttributedString>, model: NotesTextModel) {
            self.text = text
            self.model = model
            self.shown = text.wrappedValue
        }

        /// Hands the view's text to the note.
        func take(_ value: NSAttributedString) {
            let kept = NotesRichText.kept(value)
            shown = kept
            text.wrappedValue = kept
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            guard !applying else { return }
            model.isEditing = true
            model.read()
        }

        func textViewDidChange(_ textView: UITextView) {
            guard !applying else { return }
            take(textView.attributedText ?? NSAttributedString())
            model.read()
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !applying else { return }
            model.read()
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            guard !applying else { return }
            model.isEditing = false
            model.read()
        }
    }
}
#endif

#Preview {
    NotesTextView(text: .constant(AttributedString("Mars is the fourth planet from the Sun.")), model: NotesTextModel())
}
"""##
}
