//  WHAT: The kit's files: each template with the file it is written as, the types it declares and the views among
//        them, in the order a call writes them, the root first; beside them the three files a call emits from its own
//        lines (the look, the categories, the launch).
//  PIN:  EVERY TYPE THE KIT DECLARES IS LISTED HERE, so a prefix renames all of them and an app's names never clash.

import Foundation

enum KitPlan {
    struct Part: Sendable {
        /// The file's name without `.swift`, before the prefix: `NotesLibrary`.
        let name: String
        let template: String
        /// The types the file declares.
        let types: [String]
        /// The views among them.
        let views: [String]
        /// Whether the file draws something, and so has a #Preview.
        let previewed: Bool

        /// A file of one view, named after it.
        static func view(_ name: String, _ template: String) -> Part {
            Part(name: name, template: template, types: [name], views: [name], previewed: true)
        }

        /// A file of modifiers, styles or text roles: drawn in its #Preview, and no view a page shows.
        static func look(_ name: String, _ template: String, types: [String]) -> Part {
            Part(name: name, template: template, types: types, views: [], previewed: true)
        }

        /// A file of values and helpers, which draws nothing.
        static func support(_ name: String, _ template: String, types: [String]? = nil) -> Part {
            Part(name: name, template: template, types: types ?? [name], views: [], previewed: false)
        }
    }

    /// The root view a page calls: the library, which pushes the note editor.
    static let root = "NotesLibrary"

    static let parts: [Part] = [
        .view("NotesLibrary", Template.notesLibrary),
        .view("NoteEditor", Template.noteEditor),
        .view("NoteCard", Template.noteCard),
        .view("NoteCardPreview", Template.noteCardPreview),
        .view("NotesEmptyList", Template.notesEmptyList),
        .view("NotesNoResults", Template.notesNoResults),
        .view("NotesCategoryPicker", Template.notesCategoryPicker),
        .view("NotesCategoryFiling", Template.notesCategoryFiling),
        .view("NotesCategoryEditor", Template.notesCategoryEditor),
        .view("NotesCategoryButton", Template.notesCategoryButton),
        .view("NotesMaterialButton", Template.notesMaterialButton),
        .view("NotesCircleButton", Template.notesCircleButton),
        .view("NotesDismissButton", Template.notesDismissButton),
        .view("NotesBottomBlur", Template.notesBottomBlur),
        .view("NotesTextView", Template.notesTextView),
        .view("NotesFormattingBar", Template.notesFormattingBar),
        .view("NotesFormatSheet", Template.notesFormatSheet),
        .look("NotesGradientButtonStyle", Template.notesGradientButtonStyle, types: ["NotesGradientButtonStyle"]),
        .look("NotesGradientField", Template.notesGradientField, types: ["NotesGradientField"]),
        .look("NotesText", Template.notesText, types: ["NotesText", "NotesInlineTitle"]),
        .look("NotesStyle", Template.notesStyle, types: ["NotesShadow", "NotesGlass"]),
        .support("NotesTextModel", Template.notesTextModel),
        .support("NotesTextStyle", Template.notesTextStyle, types: ["NotesTextStyle", "NotesAlignment"]),
        .support("NotesRichText", Template.notesRichText),
        .support("NotesPlatform", Template.notesPlatform, types: ["NotesPlatform", "NotesHaptics"]),
        .support("NotesProtocols", Template.notesProtocols, types: ["NoteRepresentable", "NoteCategoryRepresentable"]),
        .support("NotesValue", Template.notesValue),
        .support("NotesCategory", Template.notesCategory),
        .support("NotesEntry", Template.notesEntry),
    ]

    /// The files a call emits from its lines.
    static let emitted = ["NotesLook", "NotesCategories", "NotesLaunch"]

    /// Every type the kit declares.
    static var names: [String] { parts.flatMap(\.types) + emitted }

    /// The views, the root first.
    static var views: [String] { parts.flatMap(\.views) }

    /// The root's initializer as a page calls it, with the app's note type (`Note`) and the prefix.
    static func initializer(note: String, prefix: String) -> String {
        "\(prefix)NotesLibrary(notes: [\(note)], categories: [any \(prefix)NoteCategoryRepresentable] = [], "
            + "refresh: (() async throws -> Void)? = nil, save: ((\(note)) async throws -> Void)? = nil, "
            + "delete: ((\(note)) async throws -> Void)? = nil, about: (() -> Void)? = nil, toast: ((String) -> Void)? = nil, "
            + "saveCategory: ((\(prefix)NotesCategory) async throws -> Void)? = nil, "
            + "deleteCategory: ((\(prefix)NotesCategory) async throws -> Void)? = nil)"
    }
}
