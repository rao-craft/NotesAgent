extension Template {
    static let noteEditor = ##"""
import SwiftUI

/// One note's editor: its title in the system title face, a hairline from edge to edge, then its text, attributed and
/// editable, with the formatting bar over the keyboard. In the bar, its category's chip and a more menu (a share link
/// and "Delete"), or, for a new note, "Cancel" and "Save"; while the title or the text has focus, only a button that
/// drops the keyboard. A pushed note keeps its edits as it closes, dated now when its words changed.
struct NoteEditor<Item: NoteRepresentable>: View {
    private let note: Item
    let creating: Bool
    let categories: [NotesCategory]
    /// Keeps the note: on "Save" for a new one, as the editor closes for one edited.
    var save: ((Item) -> Void)?
    /// Deletes the note once the editor has closed; without it the more menu has no "Delete".
    var delete: ((Item) -> Void)?
    /// Makes a category of a name, for the filing sheet's floating button; without it that button is not drawn.
    var create: ((String) -> NotesCategory)?
    /// Shows a toast the app draws: "Note created!".
    var toast: (@MainActor (String) -> Void)?

    @State private var title: String
    @State private var text: AttributedString
    @State private var category: String
    @State private var placeholder = ""
    @State private var filing = false
    @State private var removing = false
    @StateObject private var model = NotesTextModel()
    @FocusState private var titleFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(note: Item, creating: Bool, categories: [NotesCategory], save: ((Item) -> Void)? = nil,
         delete: ((Item) -> Void)? = nil, create: ((String) -> NotesCategory)? = nil,
         toast: (@MainActor (String) -> Void)? = nil) {
        self.note = note
        self.creating = creating
        self.categories = categories
        self.save = save
        self.delete = delete
        self.create = create
        self.toast = toast
        _title = State(initialValue: note.noteTitle)
        _text = State(initialValue: note.noteBody)
        _category = State(initialValue: note.noteCategory)
    }

    var body: some View {
        bar(
            VStack(spacing: .zero) {
                TextField(title, text: $title, prompt: Text(placeholder))
                    .font(NotesLook.editorTitle).bold()
                    .padding(.leading, {{n:editor.titleInset}})
                    .focused($titleFocused)
                    .onSubmit { model.beginEditing() }
                    .submitLabel(.next)
                    .padding(.vertical, {{n:editor.titleSpacing}})

                Divider()

                VStack(spacing: 0) {
                    NotesTextView(text: $text, model: model)
                        .overlay(alignment: .topLeading) {
                            if !model.isEditing && text.characters.isEmpty {
                                Text({{s:editor.bodyPlaceholder}})
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, {{n:editor.textInset}})
                                    .padding(.leading, {{n:editor.textInset}} + 5)
                                    .opacity(0.7)
                                    .allowsHitTesting(false)
                            }
                        }

                    #if os(iOS)
                    NotesFormattingBar(model: model)
                    #endif
                }
            }
        )
        .sheet(isPresented: $filing) {
            NotesCategoryFiling(
                categories: categories,
                current: shownCategory.id,
                file: { category = $0.id },
                create: create == nil ? nil : { name in
                    if let create { category = create(name).id }
                }
            )
        }
        .onAppear {
            if placeholder.isEmpty {
                placeholder = {{l:editor.titlePlaceholder}}.randomElement() ?? ""
            }
            if creating { titleFocused = true }
        }
        .onDisappear {
            if !creating && !removing { keepEdits() }
        }
    }

    /// The category the note is filed in, as the chip shows it.
    private var shownCategory: NotesCategory {
        NotesCategory.resolve(category, in: categories)
    }

    /// Whether the title or the text has focus.
    private var focused: Bool {
        titleFocused || model.isEditing
    }

    // MARK: The bar

    /// The bar: on iOS 26 a fixed space parts the chip from the button beside it.
    @ViewBuilder
    private func bar(_ content: some View) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content.toolbar {
                cancelItem
                if !focused {
                    chipItem
                    ToolbarSpacer(.fixed, placement: NotesPlatform.trailing)
                }
                actionsItem
            }
        } else {
            content.toolbar {
                cancelItem
                if !focused {
                    chipItem
                }
                actionsItem
            }
        }
    }

    @ToolbarContentBuilder
    private var cancelItem: some ToolbarContent {
        if creating {
            ToolbarItem(placement: NotesPlatform.leading) {
                Button({{s:editor.cancel}}) {
                    dismiss()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var chipItem: some ToolbarContent {
        ToolbarItem(placement: NotesPlatform.trailing) {
            Button {
                filing = true
                NotesHaptics.light()
            } label: {
                HStack {
                    Circle()
                        .fill(shownCategory.color.gradient)
                        .frame(width: {{n:editor.chipDot}}, height: {{n:editor.chipDot}})

                    Text(shownCategory.shownName)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                }
                .accessibilityElement()
                .accessibilityLabel({{s:editor.category}}.replacingOccurrences(of: "{name}", with: shownCategory.shownName))
            }
            .padding(.horizontal, {{n:editor.chipInset}})
        }
    }

    @ToolbarContentBuilder
    private var actionsItem: some ToolbarContent {
        ToolbarItem(placement: NotesPlatform.trailing) {
            HStack {
                if focused {
                    Button {
                        titleFocused = false
                        model.endEditing()
                    } label: {
                        Image(systemName: {{y:editor.hideKeyboard}})
                            .offset(y: 2)
                    }
                    .accessibilityLabel({{s:editor.hideKeyboard}})
                } else if !creating {
                    Menu {
                        ShareLink(item: "\(title)\n\(String(text.characters))")
                        if delete != nil {
                            Button(role: .destructive) {
                                remove()
                            } label: {
                                Label({{s:editor.delete}}, systemImage: {{y:editor.delete}})
                            }
                        }
                    } label: {
                        Label({{s:editor.more}}, systemImage: {{y:editor.more}})
                    }
                }

                if !focused && creating && save != nil {
                    Button({{s:editor.save}}) {
                        saveNew()
                    }
                    .disabled(title.isEmpty && text.characters.isEmpty)
                }
            }
        }
    }

    // MARK: Keeping the note

    /// Saves a new note, dated now, closes the sheet and toasts.
    private func saveNew() {
        var made = note
        write(into: &made, dated: true)
        save?(made)
        dismiss()
        NotesHaptics.success()
        toast?({{s:toast.noteCreated}})
    }

    /// Keeps what changed in a pushed note as it closes: dated now when its words changed.
    private func keepEdits() {
        let words = title != note.noteTitle || String(text.characters) != String(note.noteBody.characters)
        guard words || model.restyled || category != note.noteCategory else { return }
        var edited = note
        write(into: &edited, dated: words)
        save?(edited)
    }

    private func write(into item: inout Item, dated: Bool) {
        item.noteTitle = title
        item.noteBody = text
        item.noteCategory = category
        if dated { item.noteDate = Date() }
    }

    /// Closes the editor, then deletes the note once it is gone.
    private func remove() {
        removing = true
        dismiss()
        let note = note
        let delete = delete
        Task { @MainActor in
            try? await Task.sleep(for: .seconds({{m:editor.deleteDelay}}))
            withAnimation({{m:library.delete}}) {
                delete?(note)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteEditor(note: NotesEntry.samples[0], creating: false, categories: NotesEntry.sampleCategories,
                   save: { _ in }, delete: { _ in })
    }
}
"""##
}
