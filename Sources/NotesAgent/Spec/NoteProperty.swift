//  WHAT: One thing a role shows: the word a mapping line names it by (and the other words it answers to), the
//        requirement it becomes, its kind, and whether the views write it back.

import Foundation

struct NoteProperty: Sendable, Equatable {
    /// The word a line names it by: `title`.
    let key: String
    /// Other words read as this one: `text` for `body`.
    let aliases: [String]
    /// The requirement in the protocol: `noteTitle`.
    let member: String
    let kind: NoteKind
    /// Whether the views change it (the editor writes a title, a body, a category and a date back).
    let written: Bool
    /// One sentence: what it is.
    let doc: String

    init(_ key: String, _ member: String, _ kind: NoteKind, written: Bool = false, aliases: [String] = [], doc: String) {
        self.key = key; self.member = member; self.kind = kind; self.written = written; self.aliases = aliases; self.doc = doc
    }
}
