import Foundation
import XCTest
@testable import NotesAgent

/// The templates as the kit's source: every placeholder a key of the tables and every key named by one, a #Preview in
/// each file that draws and in no other, each part declaring the types and views the plan says, and every file a
/// call writes tidy.
final class TemplateTests: XCTestCase {
    func testEveryPlaceholderIsAKeyAndEveryKeyIsNamed() throws {
        let words = Words.defaults
        var named: Set<String> = []
        for part in KitPlan.parts {
            for placeholder in TemplateRender.placeholders(in: part.template) {
                named.insert(placeholder)
                let key = String(placeholder.dropFirst(2))
                let known: Bool
                switch placeholder.prefix(1) {
                case "s": known = words.strings[key] != nil
                case "l": known = words.lists[key] != nil
                case "y": known = words.symbols[key] != nil
                case "n": known = words.sizes[key] != nil
                default: known = words.motion[key] != nil
                }
                XCTAssertTrue(known, "\(part.name) names \(placeholder), which no table holds")
            }
            XCTAssertNoThrow(try TemplateRender.render(part.template, words: words), part.name)
        }
        let keys = WordTable.strings.map { "s:" + $0.key } + WordTable.lists.map { "l:" + $0.key }
            + WordTable.symbols.map { "y:" + $0.key } + WordTable.sizes.map { "n:" + $0.key } + WordTable.motion.map { "m:" + $0.key }
        XCTAssertEqual(keys.count, Set(keys).count, "a key is in its table twice")
        XCTAssertEqual(Set(keys).subtracting(named).sorted(), [], "keys no template names")
        for entry in WordTable.strings + WordTable.lists + WordTable.symbols + WordTable.sizes + WordTable.motion {
            XCTAssertFalse(entry.value.isEmpty, entry.key)
            XCTAssertFalse(entry.doc.isEmpty, entry.key)
        }
    }

    func testEveryFileThatDrawsHasAPreviewAndNoOtherDoes() {
        for part in KitPlan.parts {
            XCTAssertEqual(part.template.contains("#Preview"), part.previewed, part.name)
        }
    }

    /// The plan names every type a template declares at the top of its file, so a prefix reaches every one, and the
    /// views among them are the ones the answer lists.
    func testEachPartDeclaresTheTypesAndViewsThePlanNames() throws {
        let declaration = try NSRegularExpression(
            pattern: #"^(?:(?:public|private|fileprivate|internal|final)\s+)*(struct|enum|class|protocol|actor)\s+([A-Z][A-Za-z0-9_]*)([^{]*)\{"#,
            options: .anchorsMatchLines)
        var declared: [String] = []
        for part in KitPlan.parts {
            let text = part.template
            var types: [String] = [], views: [String] = []
            for match in declaration.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let name = Range(match.range(at: 2), in: text), let rest = Range(match.range(at: 3), in: text) else { continue }
                let type = String(text[name])
                if !types.contains(type) { types.append(type) }
                let isView = text[rest].range(of: #"[:,]\s*(View|NSViewRepresentable|UIViewRepresentable)(?![A-Za-z])"#, options: .regularExpression) != nil
                if isView, !views.contains(type) { views.append(type) }
            }
            XCTAssertEqual(types, part.types, part.name)
            XCTAssertEqual(views, part.views, part.name)
            declared += types
        }
        XCTAssertEqual(declared.count, Set(declared).count, "a type is declared in two files")
        XCTAssertEqual(Set(KitPlan.names).subtracting(declared), Set(KitPlan.emitted), "the plan names a type no file declares")
        XCTAssertEqual(KitPlan.views.first, KitPlan.root)
    }

    /// No template imports Granite or holds global mutable state; each starts with its imports.
    func testTheTemplatesArePlainSwiftUI() {
        for part in KitPlan.parts {
            XCTAssertFalse(part.template.contains("import Granite"), part.name)
            XCTAssertNil(part.template.range(of: #"(?m)^(?:static |nonisolated\(unsafe\) )?var "#, options: .regularExpression), part.name)
            XCTAssertNil(part.template.range(of: #"(?m)^    static var [a-zA-Z]+: [^{]+= "#, options: .regularExpression),
                         "\(part.name) keeps a static var")
            XCTAssertTrue(part.template.hasPrefix("import "), part.name)
        }
    }

    /// Every template is written as the call writes it: tidied, it is the same text.
    func testEveryTemplateIsWrittenTidy() {
        for part in KitPlan.parts {
            XCTAssertEqual(TemplateRender.tidy(part.template.components(separatedBy: "\n")), part.template + "\n", part.name)
        }
    }

    /// And so is every file of the Seer call, the emitted ones and the conformance among them.
    func testEveryFileOfTheSeerCallIsTidy() throws {
        let (_, result) = try Fixture.seer()
        for path in result.paths {
            let text = try String(contentsOfFile: path, encoding: .utf8)
            let name = URL(fileURLWithPath: path).lastPathComponent
            XCTAssertTrue(text.hasSuffix("}\n") || text.hasSuffix(")\n"), name)
            XCTAssertFalse(text.hasSuffix("\n\n"), name)
            XCTAssertFalse(text.contains("\n\n\n"), name)
            XCTAssertNil(text.range(of: #"[ \t]\n"#, options: .regularExpression), "\(name) has trailing space")
            XCTAssertNil(text.range(of: #"\{\n\s*\n"#, options: .regularExpression), "\(name) has a blank line after a brace")
            XCTAssertNil(text.range(of: #"\n\s*\n\s*\}"#, options: .regularExpression), "\(name) has a blank line before a brace")
            XCTAssertFalse(text.contains("{{"), "\(name) keeps a placeholder")
        }
    }

    /// The words a template writes come from the call: the general category's name in the delete message, a list
    /// as an array, a size as a number.
    func testAPlaceholderIsWrittenAsSwift() throws {
        var words = Words.defaults
        words.strings["picker.title"] = "Pick \"one\"\nnow"
        words.lists["editor.titlePlaceholder"] = ["A", "B"]
        words.sizes["grid.minimum"] = "180"
        words.motion["library.delete"] = ".snappy"
        let picker = try TemplateRender.render(Template.notesCategoryPicker, words: words)
        XCTAssertTrue(picker.contains(#""Pick \"one\"\nnow""#))
        let editor = try TemplateRender.render(Template.noteEditor, words: words)
        XCTAssertTrue(editor.contains(#"placeholder = ["A", "B"].randomElement() ?? """#))
        XCTAssertTrue(editor.contains("withAnimation(.snappy) {"))
        let library = try TemplateRender.render(Template.notesLibrary, words: words)
        XCTAssertTrue(library.contains("GridItem(.adaptive(minimum: 180))"))
        let category = try TemplateRender.render(Template.notesCategoryEditor, words: words, replacing: ["general": "Unsorted"])
        XCTAssertTrue(category.contains("will be moved to the Unsorted category."))
        XCTAssertThrowsError(try TemplateRender.render("Text({{s:no.such}})", words: words)) { error in
            XCTAssertEqual(error as? TemplateRender.Failure, .unknown("s:no.such"))
        }
    }
}
