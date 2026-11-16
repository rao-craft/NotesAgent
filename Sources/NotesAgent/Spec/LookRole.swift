//  WHAT: The look roles the views read through `NotesLook`, and what each falls back to when the call maps none: the
//        value the notes screens are drawn in, written with system names, so the views build in any app. A `look`
//        line maps a role to the app's own name (`accent = Color.accent`, `title = Font.brandTitle`).

import Foundation

struct LookRole: Sendable {
    enum Kind: Sendable { case color, font }

    let name: String
    let kind: Kind
    /// Swift for the role when the call maps none.
    let fallback: String
    let doc: String

    init(_ name: String, _ kind: Kind, _ fallback: String, _ doc: String) {
        self.name = name; self.kind = kind; self.fallback = fallback; self.doc = doc
    }

    var swiftType: String { kind == .color ? "Color" : "Font" }

    static let all: [LookRole] = [
        LookRole("accent", .color, "Color.accentColor", "the tint: the bar's glyphs, the empty grid's action, a new category's plus, a style that is on"),
        LookRole("card", .color, "NotesPlatform.dynamic(light: .white, dark: .white.opacity(0.1))", "a card's fill, and where a category's gradient starts"),
        LookRole("cardShadow", .color, "NotesPlatform.dynamic(light: Color(red: 0.557, green: 0.557, blue: 0.557).opacity(0.14), dark: .clear)", "a card's shadow"),
        LookRole("buttonShadow", .color, "NotesPlatform.dynamic(light: Color(red: 0.557, green: 0.557, blue: 0.557).opacity(0.4), dark: .clear)", "the shadow under a category's button and the name field"),
        LookRole("panel", .color, "NotesPlatform.dynamic(light: .white, dark: Color(white: 0.1))", "where the category editor's background starts, above its colour"),
        LookRole("titleColor", .color, "Color.primary.opacity(0.75)", "the colour of `title` text"),
        LookRole("noteColor", .color, "Color.primary.opacity(0.6)", "the colour of `note` and `note2` text"),
        LookRole("title", .font, "Font.system(size: 24, weight: .regular, design: .serif)", "titles in the bar, and an empty state's title (drawn bold)"),
        LookRole("note", .font, "Font.system(size: 18, weight: .light, design: .serif)", "an empty filter's line (drawn italic)"),
        LookRole("note2", .font, "Font.system(size: 16, weight: .light, design: .serif)", "the empty grid's line (drawn italic) and its action"),
        LookRole("cardTitle", .font, "Font.system(size: 16, weight: .medium, design: .serif)", "a card's title"),
        LookRole("cardDate", .font, "Font.system(size: 14, weight: .regular, design: .serif)", "a card's date"),
        LookRole("cardText", .font, "Font.system(size: 12, weight: .regular, design: .serif)", "a card's lines of text"),
        LookRole("cardCategory", .font, "Font.system(size: 12, weight: .regular, design: .serif)", "a card's category name"),
        LookRole("editorTitle", .font, "Font.title", "the editor's title (drawn bold)"),
    ]

    static func named(_ name: String) -> LookRole? { all.first { $0.name.lowercased() == name.lowercased() } }
}
