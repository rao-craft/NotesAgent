import Foundation
import XCTest
@testable import NotesAgent

/// Every line a call gives, read: what each field accepts, and each refusal with its reason.
final class MappingLineTests: XCTestCase {
    func testANoteLineMapsEveryWordAndANewNote() throws {
        let mapping = try MappingLine.parse(#"note: Note title=title body=body category=category date=createdAt cloud=true new=Note(id: UUID().uuidString, title: "", body: "", category: "General", createdAt: Date())"#)
        XCTAssertEqual(mapping.role, .note)
        XCTAssertEqual(mapping.type, "Note")
        XCTAssertEqual(mapping.assignments.map(\.property.key), ["title", "body", "category", "date", "cloud", "new"])
        XCTAssertEqual(mapping.source(of: "date"), .path("createdAt"))
        XCTAssertEqual(mapping.source(of: "cloud"), .expression("true"), "`true` is Swift, not a field")
        XCTAssertEqual(mapping.source(of: "new"), .expression(#"Note(id: UUID().uuidString, title: "", body: "", category: "General", createdAt: Date())"#))
    }

    func testWordsAliasesPathsAndSwiftAreRead() throws {
        let mapping = try MappingLine.parse(#"entry: Journal.Entry id=slug, name = headline ?? "Untitled", text=value.content, folder=meta?.mood created=writtenAt server=isRemote"#)
        XCTAssertEqual(mapping.role, .note)
        XCTAssertEqual(mapping.type, "Journal.Entry")
        XCTAssertEqual(mapping.id, .path("slug"))
        XCTAssertEqual(mapping.source(of: "title"), .expression(#"headline ?? "Untitled""#))
        XCTAssertEqual(mapping.source(of: "body"), .path("content"))
        XCTAssertEqual(mapping.source(of: "category"), .path("meta?.mood"))
        XCTAssertEqual(mapping.source(of: "date"), .path("writtenAt"))
        XCTAssertEqual(mapping.source(of: "cloud"), .path("isRemote"))
        XCTAssertEqual(mapping.fileStem, "JournalEntry")
    }

    func testACategoryLineMapsItsIdNameAndColour() throws {
        let mapping = try MappingLine.parse("category: Mood id=slug name=title colour=tint")
        XCTAssertEqual(mapping.role, .category)
        XCTAssertEqual(mapping.id, .path("slug"))
        XCTAssertEqual(mapping.assignments.map(\.property.key), ["name", "color"])
    }

    func testALineItCannotReadIsRefusedWithWhatItTakes() {
        let refused: [(String, String)] = [
            ("note Note title=title", "has no colon"),
            ("post: Note title=title", "`post` is not a role: a line starts with note or category"),
            ("note: note title=title", "is not a type name"),
            ("note: Note heading=title author=writer", "`author` is not something a note shows; a note maps id, title, body, category, date, cloud, new"),
            ("note: Note title=title name=headline", "`title` is mapped twice"),
            ("note: Note new=Note(title: value.title)", "`new` makes a new Note with no value to read"),
            ("note: Note title=", "`title` has `=` and no value"),
            ("note: Note", "it maps nothing"),
            ("category: Mood tint name=name", "`tint` is not `word=value`"),
        ]
        for (line, reason) in refused {
            XCTAssertThrowsError(try MappingLine.parse(line), line) { error in
                XCTAssertTrue("\(error)".contains(reason), "\(line): \(error)")
            }
        }
    }
}

final class WordLineTests: XCTestCase {
    func testStringsListsSymbolsSizesAndMotionTakeTheirValues() {
        var problems: [String] = []
        let words = WordLines.read(
            strings: ["library.title = Library", #"category.deleteMessage = "Sure?\nAll of \"{name}\" goes.""#,
                      "editor.titlePlaceholder = Name it... | Or not"],
            symbols: ["library.new = square.and.pencil"],
            sizes: ["grid.minimum = 180", "picker.detent = 0.5", "card.lines = 4"],
            motion: ["library.filter = .spring(response: 0.4, dampingFraction: 0.8)", "editor.deleteDelay = 0.3",
                     "picker.edit = Animation.snappy"],
            problems: &problems)
        XCTAssertEqual(problems, [])
        XCTAssertEqual(words.strings["library.title"], "Library")
        XCTAssertEqual(words.strings["category.deleteMessage"], "Sure?\nAll of \"{name}\" goes.")
        XCTAssertEqual(words.lists["editor.titlePlaceholder"], ["Name it...", "Or not"])
        XCTAssertEqual(words.symbols["library.new"], "square.and.pencil")
        XCTAssertEqual(words.sizes["grid.minimum"], "180")
        XCTAssertEqual(words.sizes["picker.detent"], "0.5")
        XCTAssertEqual(words.motion["library.filter"], ".spring(response: 0.4, dampingFraction: 0.8)")
        XCTAssertEqual(words.motion["editor.deleteDelay"], "0.3")
        XCTAssertEqual(words.motion["picker.edit"], ".snappy")
        // What a call leaves out keeps the original's words.
        XCTAssertEqual(words.strings["library.emptyTitle"], "This looks a little empty...")
        XCTAssertEqual(words.symbols["library.filter"], "line.3.horizontal.decrease.circle")
    }

    func testEveryLineItCannotReadIsRefusedNamingItsField() {
        var problems: [String] = []
        _ = WordLines.read(
            strings: ["library.heading = Notes", "library.title = A", "library.title = B", "library.title"],
            symbols: ["library.new = Square And Pencil", "grid.new = plus"],
            sizes: ["grid.minimum = wide", "card.lines = 2.5", "picker.detent = 1.5", "grid.minimum = -1"],
            motion: ["library.filter = .wobbly", "editor.deleteDelay = soon", "grid.fade = .bouncy"],
            problems: &problems)
        let expected = [
            "strings `library.heading = Notes`: `library.heading` is not a string key; the keys for library are",
            "strings `library.title = B`: `library.title` is set twice",
            "strings `library.title`: a line is `key = value`",
            "symbols `library.new = Square And Pencil`: `Square And Pencil` is not an SF Symbol's name",
            "symbols `grid.new = plus`: `grid.new` is not a symbol key",
            "sizes `grid.minimum = wide`: `wide` is not a size",
            "sizes `card.lines = 2.5`: `card.lines` is a count",
            "sizes `picker.detent = 1.5`: `picker.detent` is a fraction of the screen",
            "sizes `grid.minimum = -1`: `-1` is not a size",
            "motion `library.filter = .wobbly`: `.wobbly` is not an animation",
            "motion `editor.deleteDelay = soon`: `editor.deleteDelay` is a delay",
            "motion `grid.fade = .bouncy`: `grid.fade` is not a motion key",
        ]
        XCTAssertEqual(problems.count, expected.count, problems.joined(separator: "\n"))
        for (problem, start) in zip(problems, expected) { XCTAssertTrue(problem.hasPrefix(start), "\(problem)\nwants \(start)") }
    }
}

final class LookCategoryLaunchLineTests: XCTestCase {
    func testALookLineMapsARoleToTheAppsName() throws {
        let accent = try LookLine.parse("accent = Color.accent")
        XCTAssertEqual(accent.role.name, "accent")
        XCTAssertEqual(accent.swift, "Color.accent")
        XCTAssertEqual(try LookLine.parse("title = .brandTitle").swift, "Font.brandTitle")
        XCTAssertEqual(try LookLine.parse(#"card = Color("CardFill")"#).swift, #"Color("CardFill")"#)
        for (line, reason) in [("tint = Color.accent", "`tint` is not a look role; the roles are accent, card"),
                               ("title = Font.custom(\"Serif\"", "is not one Swift expression"),
                               ("accent", "a line is `key = value`")] {
            XCTAssertThrowsError(try LookLine.parse(line), line) { XCTAssertTrue("\($0)".contains(reason), "\($0)") }
        }
    }

    func testCategoryLinesNameTheGeneralTheMemoriesAndTheListed() {
        var problems: [String] = []
        let spec = CategoryLine.read(["general = General brown", "memory = Memory green", "Space brown",
                                      "\"Machine Learning\" brown", "Ancient History #AE9060", "Music = accent", "color = grey"],
                                     problems: &problems)
        XCTAssertEqual(problems, [])
        XCTAssertEqual(spec.general, .init(name: "General", color: "Color.brown"))
        XCTAssertEqual(spec.memory, .init(name: "Memory", color: "Color.green"))
        XCTAssertEqual(spec.listed.map(\.name), ["Space", "Machine Learning", "Ancient History", "Music"])
        XCTAssertEqual(spec.listed[2].color, "Color(red: 0.682, green: 0.565, blue: 0.376)")
        XCTAssertEqual(spec.listed[3].color, "NotesLook.accent")
        XCTAssertEqual(spec.unlisted, "Color.gray")
    }

    func testACategoryLineItCannotReadIsRefused() {
        var problems: [String] = []
        _ = CategoryLine.read(["Space brown", "space teal", "general = General", "general = Main", "Work = plaid",
                               "\"Open brown", "color = beige"], problems: &problems)
        let expected = ["`space` is named twice", "`general` is said twice", "`plaid` is not a colour", "the quote is not closed",
                        "`beige` is not a colour"]
        XCTAssertEqual(problems.count, expected.count, problems.joined(separator: "\n"))
        for (problem, reason) in zip(problems, expected) {
            XCTAssertTrue(problem.hasPrefix("categories `"), problem)
            XCTAssertTrue(problem.contains(reason), "\(problem)\nwants \(reason)")
        }
    }

    func testALaunchLineNamesADestinationAndItsState() throws {
        XCTAssertTrue(try LaunchLine.parse("library = grid") == ("library", .grid))
        XCTAssertTrue(try LaunchLine.parse("library.memories = memories") == ("library.memories", .memories))
        XCTAssertTrue(try LaunchLine.parse("library.categories = categories") == ("library.categories", .categories))
        XCTAssertTrue(try LaunchLine.parse("library.new = new") == ("library.new", .new))
        XCTAssertTrue(try LaunchLine.parse("note = editor space-001") == ("note", .editor("space-001")))
        XCTAssertTrue(try LaunchLine.parse(#"note = editor "Launch windows""#) == ("note", .editor("Launch windows")))
        XCTAssertEqual(LaunchState.editor("space-001").swift, #".editor("space-001")"#)
        // A new note already written: its title and text in quotes, a line break written `\n` or kept as it is.
        let body = "Mars and Earth line up.\n\nPerseverance left in July 2020, \"on time\"."
        XCTAssertTrue(try LaunchLine.parse(#"note = new "Launch windows" "Mars and Earth line up.\n\nPerseverance left in July 2020, \"on time\".""#)
                      == ("note", .draft(title: "Launch windows", body: body)))
        XCTAssertTrue(try LaunchLine.parse("note = new \"Launch windows\"  \"Mars and Earth line up.\n\nPerseverance left in July 2020, \\\"on time\\\".\"")
                      == ("note", .draft(title: "Launch windows", body: body)))
        XCTAssertTrue(try LaunchLine.parse(#"note = new "Launch windows""#) == ("note", .draft(title: "Launch windows", body: "")))
        XCTAssertEqual(LaunchState.draft(title: "Launch windows", body: "One.\n\nTwo \"three\".").swift,
                       #".draft(title: "Launch windows", body: "One.\n\nTwo \"three\".")"#)
        for (line, reason) in [("note = open space-001", "is not a state; a state is grid, memories, categories, new (with a new note's title"),
                               ("note = editor", "`editor` names the note it opens"),
                               ("my note = grid", "is not a destination's name"),
                               ("library = grid now", "`grid` takes nothing after it"),
                               ("note = new Launch windows", "`new` opens a new note, empty or written: its title and text each in quotes"),
                               (#"note = new "Launch" "windows" "now""#, "its title and text each in quotes"),
                               (#"note = new "Launch windows"#, "the quote is not closed")] {
            XCTAssertThrowsError(try LaunchLine.parse(line), line) { XCTAssertTrue("\($0)".contains(reason), "\($0)") }
        }
    }
}

/// A whole call refused at once: every problem named with its field, nothing written.
final class RefusalTests: XCTestCase {
    func testEveryProblemOfACallIsRefusedTogether() throws {
        let folder = try Fixture.folder()
        try Fixture.write("struct Entry {\n    let slug: String\n    var headline: String\n    var tags: [String]\n}\n",
                          to: folder.appendingPathComponent("Models/Entry.swift"))
        let input = NotesAgent.Input(prefix: "kit", mappings: ["note: Entry title=heading category=tags cloud=headline", "note: Entry title=headline"],
                                     imports: ["Seer Kit"], look: ["tint = Color.red"], strings: ["library.heading = Notes"],
                                     categories: ["Work = plaid"], launch: ["note = open"], directory: folder.path)
        XCTAssertThrowsError(try NotesAgent.write(input, note: { _ in }, yield: { _ in })) { error in
            guard case NotesError.problems(let reasons) = error else { return XCTFail("\(error)") }
            let expected = [
                "mappings: note is mapped twice",
                "imports: `Seer Kit` is not a module name",
                "mappings: `Entry` has no `id`",
                "mappings: note title=heading: `Entry` has no `heading`: its fields are slug, headline, tags",
                "mappings: note category=tags: `tags` is `[String]`, and `category` shows text",
                "mappings: note cloud=headline: `headline` is `String`, and `cloud` shows a Bool",
                "mappings: `Entry` has no `id`",
                "strings `library.heading = Notes`",
                "look `tint = Color.red`",
                "categories `Work = plaid`",
                "launch `note = open`",
                "prefix: `kit` is not a prefix",
            ]
            XCTAssertEqual(reasons.count, expected.count, reasons.joined(separator: "\n"))
            for (reason, start) in zip(reasons, expected) { XCTAssertTrue(reason.hasPrefix(start), "\(reason)\nwants \(start)") }
            XCTAssertTrue("\(error)".hasPrefix("\(expected.count) problems with the call, so nothing was written:"))
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), ["Models"], "nothing was written")
    }
}
