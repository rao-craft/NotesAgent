import Foundation
import XCTest
@testable import NotesAgent

/// What a call writes: which files and names, Seer's output as its scorecard and spec read it, the same bytes on a
/// second run, a prefix on every name, conformances that write back what they can.
final class NotesEmitTests: XCTestCase {
    func testTheSeerCallWritesTheKitAndOneConformance() throws {
        let (_, result) = try Fixture.seer()
        let names = result.paths.map { URL(fileURLWithPath: $0).lastPathComponent }
        let kit = KitPlan.parts.map { $0.name + ".swift" } + KitPlan.emitted.map { $0 + ".swift" }
        XCTAssertEqual(names, kit + ["Note+Note.swift"])
        for path in result.paths {
            XCTAssertTrue(path.contains("/Components/Notes/"), path)
        }
        XCTAssertTrue(result.paths.last?.hasSuffix("/Components/Notes/Conformances/Note+Note.swift") == true)
        XCTAssertEqual(result.conformances, ["Note: note"])
        XCTAssertEqual(result.views, KitPlan.views)
        XCTAssertEqual(result.notes, [], "the Seer call leaves nothing for the app to do")
        XCTAssertEqual(result.roots, [
            "NotesLibrary(notes: [Note], categories: [any NoteCategoryRepresentable] = [], refresh: (() async throws -> Void)? = nil, "
                + "save: ((Note) async throws -> Void)? = nil, delete: ((Note) async throws -> Void)? = nil, about: (() -> Void)? = nil, "
                + "toast: ((String) -> Void)? = nil, saveCategory: ((NotesCategory) async throws -> Void)? = nil, "
                + "deleteCategory: ((NotesCategory) async throws -> Void)? = nil)",
        ])
        XCTAssertEqual(Set(result.expected.map(\.name)), Set(result.made.map(\.name)))
        XCTAssertTrue(result.made.allSatisfy { $0.state == .written })
    }

    func testTheConformanceReadsAndWritesSeerKitsNote() throws {
        let (_, result) = try Fixture.seer()
        let text = try Fixture.text(result.paths, "Note+Note.swift")
        XCTAssertEqual(text, """
            import Foundation
            import SeerKit

            /// A `Note` as the notes views show and edit it.
            extension Note: NoteRepresentable {
                var noteTitle: String {
                    get { NotesValue.text(self.title) }
                    set { NotesValue.assign(newValue, to: &self.title) }
                }
                var noteBody: AttributedString {
                    get { NotesValue.rich(self.body) }
                    set { NotesValue.assign(newValue, to: &self.body) }
                }
                var noteCategory: String {
                    get { NotesValue.text(self.category) }
                    set { NotesValue.assign(newValue, to: &self.category) }
                }
                var noteDate: Date {
                    get { NotesValue.date(self.createdAt) }
                    set { NotesValue.assign(newValue, to: &self.createdAt) }
                }
                /// A new, empty note the editor starts from.
                static var notesNew: Note? { Note(id: UUID().uuidString, title: "", body: "", category: "General", createdAt: Date()) }
            }

            """)
    }

    func testTheCallsLinesAreWrittenIntoTheLookTheCategoriesAndTheLaunch() throws {
        let (_, result) = try Fixture.seer()
        let look = try Fixture.text(result.paths, "NotesLook.swift")
        XCTAssertTrue(look.contains("    static var accent: Color { Color.accent }"))
        XCTAssertTrue(look.contains("    static var title: Font { Font.brandTitle }"))
        XCTAssertTrue(look.contains("    static var note: Font { Font.brandNote }"))
        XCTAssertTrue(look.contains("    static var note2: Font { Font.brandNote2 }"))
        XCTAssertTrue(look.contains("    static var card: Color { NotesPlatform.dynamic(light: .white, dark: .white.opacity(0.1)) }"),
                      "a role left out keeps the original's value")
        let categories = try Fixture.text(result.paths, "NotesCategories.swift")
        XCTAssertTrue(categories.contains(#"    static let general = NotesCategory(name: "General", color: Color.brown)"#))
        XCTAssertTrue(categories.contains(#"    static let memory: NotesCategory? = NotesCategory(name: "Memory", color: Color.green)"#))
        for name in ["Space", "Cooking", "Machine Learning", "Ancient History", "Music Theory"] {
            XCTAssertTrue(categories.contains(#"        NotesCategory(name: "\#(name)", color: Color.brown),"#), name)
        }
        let launch = try Fixture.text(result.paths, "NotesLaunch.swift")
        XCTAssertTrue(launch.contains(#"        switch UserDefaults.standard.string(forKey: "destination") {"#))
        XCTAssertTrue(launch.contains(#"        case "library": return .grid"#))
        XCTAssertTrue(launch.contains(#"        case "note": return .editor("space-001")"#))
        let picker = try Fixture.text(result.paths, "NotesCategoryEditor.swift")
        XCTAssertTrue(picker.contains(#"will be moved to the General category.".replacingOccurrences(of: "{name}""#),
                      "the general category's name is written into the message, the deleted one's at run time")
    }

    /// Seer's scorecard, area `library`: every `code` item but B-library-13, the mock notes, which `$mocks` seeds.
    func testEverySeerScorecardCodeItemOfTheLibraryMatches() throws {
        let (_, result) = try Fixture.seer()
        let code = try Fixture.all(result.paths)
        let items: [(String, [String])] = [
            ("B-library-9", [#"LazyVGrid"#, #"GridItem\(\s*\.adaptive\(\s*minimum:\s*160(\.0)?\s*\)"#]),
            ("B-library-10", [#"ellipsis\.circle"#, #"line\.3\.horizontal\.decrease\.circle"#, #"brain\.fill"#, #"book\.pages"#]),
            ("B-library-11", [#"note\.text"#, #"This looks a little empty\.\.\."#, #"Create a note!"#, #"pencil\.and\.scribble"#,
                              #"No Notes"#, #"Start writing and assign a category!"#]),
            ("B-library-12", [#"Select a Category"#, #"Edit your Categories"#, #"All notes"#, #"Change Note Category"#,
                              #"Create and assign new category"#, #"Save and Assign"#, #"Name your category\.\.\."#,
                              #"Confirm Category Deletion"#, #"will be moved to the General category\."#, #"Yes, delete this category"#]),
            ("B-library-14", [#"Title your note\.\.\."#, #"Title your imagination\.\.\."#, #"Title your inspiration\.\.\."#,
                              #"What.s on your mind\?"#]),
            ("B-library-15", [#"arrow\.uturn\.backward"#, #"arrow\.uturn\.forward"#, #"textformat"#, #"keyboard\.chevron\.compact\.down"#]),
            ("B-library-16", [#"\"Format\""#, #"Underlined"#, #"Strikethrough"#, #"Font Size"#, #"Highlight"#, #"text\.alignleft"#,
                              #"text\.justify"#]),
            ("B-library-17", [#"AttributedString"#, #"Note created!"#]),
        ]
        for (id, patterns) in items {
            for pattern in patterns {
                XCTAssertNotNil(code.range(of: pattern, options: .regularExpression), "\(id): \(pattern)")
            }
        }
    }

    /// Every string the spec quotes for the Library and the Note editor is in the code, where OCR finds it.
    func testEveryQuotedStringOfTheLibraryAndTheEditorIsWritten() throws {
        let (_, result) = try Fixture.seer()
        let code = try Fixture.all(result.paths)
        let quoted = [
            // Library
            "Library", "Memories", "About Seer", "Untitled", "No content...", "This looks a little empty...", "Create a note!", "No Notes",
            "Start writing and assign a category!", "General", "Memory", "Change category", "Delete", "Edit", "Done",
            "Select a Category", "Edit your Categories", "All notes", "Edit Category", "New Category", "Change Note Category",
            "Create and assign new category", "Create a new category", "Save and Assign", "Cancel", "Category created!",
            "And assigned to your note", "Name your category...", "Save", "Confirm Category Deletion",
            #"Are you sure you want to delete this category?\nAll notes in the \"{name}\" category will be moved to the General category."#,
            "Yes, delete this category",
            // Note editor
            "space-001", "Title your note...", "Title your imagination...", "Title your inspiration...", "What's on your mind?",
            "Note created!", "Format", "Style", "Bold", "Italic", "Underlined", "Strikethrough", "Font Size", "{size} pt",
            "Alignment", "Color", "Text", "Highlight",
        ]
        for string in quoted {
            XCTAssertTrue(code.contains("\"\(string)\""), string)
        }
    }

    func testTheSameCallWritesTheSameBytes() throws {
        let first = try Fixture.seer(), second = try Fixture.seer()
        func files(_ run: (folder: URL, result: NotesResult)) throws -> [String: String] {
            Dictionary(uniqueKeysWithValues: try run.result.paths.map {
                (String($0.dropFirst(run.folder.path.count)), try String(contentsOfFile: $0, encoding: .utf8))
            })
        }
        XCTAssertEqual(try files(first), try files(second))
        // Again into the same folder: the same files, each one rewritten.
        var input = try Fixture.example("seer")
        input.directory = first.folder.path
        let again = try NotesAgent.write(input, note: { _ in }, yield: { _ in })
        XCTAssertEqual(again.paths, first.result.paths)
        XCTAssertTrue(again.made.allSatisfy { $0.state == .rewritten })
        XCTAssertEqual(try files((first.folder, again)), try files(first))
    }

    func testAPrefixRenamesEveryTypeAndFileOfTheKit() throws {
        let (_, result) = try Fixture.seer(prefix: "Kit")
        for path in result.paths where !path.contains("/Conformances/") {
            XCTAssertTrue(URL(fileURLWithPath: path).lastPathComponent.hasPrefix("Kit"), path)
        }
        let code = try Fixture.all(result.paths)
        for name in KitPlan.names {
            XCTAssertNil(code.range(of: "(?<![A-Za-z0-9_])\(name)(?![A-Za-z0-9_])", options: .regularExpression), "\(name) is left unprefixed")
            XCTAssertTrue(code.contains("Kit" + name), "Kit\(name)")
        }
        XCTAssertTrue(try Fixture.text(result.paths, "Note+Note.swift").contains("extension Note: KitNoteRepresentable {"))
        XCTAssertTrue(result.roots[0].hasPrefix("KitNotesLibrary(notes: [Note], categories: [any KitNoteCategoryRepresentable] = []"))
        XCTAssertEqual(result.views.first, "KitNotesLibrary")
    }

    /// What the editor changes is written back where the app's type lets it; where not, it is read and said.
    func testAFieldTheEditorCannotWriteIsReadOnlyAndSaid() throws {
        let folder = try Fixture.folder()
        try Fixture.write("""
            import Foundation
            import SwiftUI

            struct Page {
                let id: UUID
                let heading: String
                var text: String
                var meta: Meta?
                var written: Double
            }

            struct Meta {
                var shelf: String
            }

            struct Shelf {
                var slug: String
                var title: String
                var tint: Color
            }
            """, to: folder.appendingPathComponent("App/Models.swift"))
        let input = NotesAgent.Input(mappings: ["page: Page title=heading body=text category=meta?.shelf date=written",
                                                "folder: Shelf id=slug name=title color=tint"], directory: folder.path)
        let result = try NotesAgent.write(input, note: { _ in }, yield: { _ in })
        let page = try Fixture.text(result.paths, "Page+Note.swift")
        XCTAssertTrue(page.contains("""
                /// Read only: `heading` is a `let`, so the editor's changes to it stay in the view.
                var noteTitle: String {
                    get { NotesValue.text(self.heading) }
                    set {}
                }
            """), page)
        XCTAssertTrue(page.contains("        set { NotesValue.assign(newValue, to: &self.text) }"))
        XCTAssertTrue(page.contains("    /// Read only: `meta?.shelf` reads through an optional, so the editor's changes to it stay in the view."))
        XCTAssertTrue(page.contains("        set { NotesValue.assign(newValue, to: &self.written) }"))
        XCTAssertFalse(page.contains("notesNew"), "no `new=`, no new note")
        let shelf = try Fixture.text(result.paths, "Shelf+NoteCategory.swift")
        XCTAssertTrue(shelf.contains("import SwiftUI"))
        XCTAssertTrue(shelf.contains("    var noteCategoryID: String { NotesValue.text(self.slug) }"))
        XCTAssertTrue(shelf.contains("    var noteCategoryColor: Color { NotesValue.color(self.tint) }"))
        XCTAssertEqual(result.notes, [
            "Page's title is shown and never written back, since `heading` is a `let`: the editor's changes to it stay in the view.",
            "Page's category is shown and never written back, since `meta?.shelf` reads through an optional: the editor's changes to it stay in the view.",
            "The note line has no `new=`: nothing makes a note (no plus, no \"Create a note!\"), so add `new=` with Swift that makes an empty one.",
            "No `launch` line: a launch with `-destination <name>` opens the grid as it is.",
        ])
        XCTAssertTrue(result.roots[0].hasPrefix("NotesLibrary(notes: [Page]"))
    }

    func testATypeInALocalPackageIsImported() throws {
        let folder = try Fixture.folder()
        try Fixture.write(Fixture.seerKitPackage, to: folder.appendingPathComponent("Packages/SeerKit/Package.swift"))
        try Fixture.write(Fixture.seerKitNote, to: folder.appendingPathComponent("Packages/SeerKit/Sources/SeerKit/Note.swift"))
        let input = NotesAgent.Input(mappings: ["note: Note title=title body=body category=category date=created_at"], directory: folder.path)
        let result = try NotesAgent.write(input, note: { _ in }, yield: { _ in })
        let text = try Fixture.text(result.paths, "Note+Note.swift")
        XCTAssertTrue(text.hasPrefix("import Foundation\nimport SeerKit\n"))
        XCTAssertTrue(text.contains("NotesValue.date(self.createdAt)"), "the path in the type's spelling")
        XCTAssertTrue(result.notes.contains("`Note` is declared in SeerKit, so the conformances import it."))
        XCTAssertTrue(result.notes.contains("note date: `created_at` is `createdAt` on Note."))
    }
}
