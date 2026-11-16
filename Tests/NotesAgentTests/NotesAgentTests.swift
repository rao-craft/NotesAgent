import Foundation
import GraniteAgents
import XCTest
@testable import NotesAgent

/// The package as an app finds it: by its record, with the schema a model is shown and the guide a host prompts with.
final class NotesAgentTests: XCTestCase {
    func testTheRecordIsFoundWithNothingListed() throws {
        let notes = try XCTUnwrap(GraniteRoster.discovered().package("notes"), "the record is in this test binary")
        XCTAssertEqual(notes.module, "NotesAgent")
        XCTAssertEqual(notes.summary, NotesAgent.summary)
    }

    func testTheSchemaIsWhatAModelIsShown() {
        let notes = AnyAgentPackage(NotesAgent.self)
        XCTAssertEqual(notes.schema, .object([
            .init(name: "into", schema: .string, required: false),
            .init(name: "prefix", schema: .string, required: false),
            .init(name: "mappings", schema: .array(.string), required: false),
            .init(name: "imports", schema: .array(.string), required: false),
            .init(name: "look", schema: .array(.string), required: false),
            .init(name: "strings", schema: .array(.string), required: false),
            .init(name: "symbols", schema: .array(.string), required: false),
            .init(name: "sizes", schema: .array(.string), required: false),
            .init(name: "motion", schema: .array(.string), required: false),
            .init(name: "categories", schema: .array(.string), required: false),
            .init(name: "launch", schema: .array(.string), required: false),
            .init(name: "directory", schema: .string, required: false),
        ]))
        XCTAssertTrue(notes.takesDirectory)
        XCTAssertEqual(Set(notes.fields.keys), ["into", "prefix", "mappings", "imports", "look", "strings", "symbols", "sizes",
                                                 "motion", "categories", "launch"], "a note beside every field the model sees")
        XCTAssertEqual(notes.makes.map(\.kind), ["view", "conformance"])
    }

    func testTheGuideTeachesTheLineTheRootAndACall() {
        let guide = AnyAgentPackage(NotesAgent.self).guide
        for word in ["mappings", "note (", "category (", "value", "id=", "new=", "imports", "look", "strings", "symbols",
                     "sizes", "motion", "categories", "launch", "NotesLibrary", "-destination"] {
            XCTAssertTrue(guide.contains(word), "the guide says \(word)")
        }
        for role in NoteRole.allCases {
            for property in role.properties { XCTAssertTrue(guide.contains(property.key), "the guide names \(role).\(property.key)") }
        }
        XCTAssertEqual(guide.components(separatedBy: "{\"").count - 1, 1, "one example call")
        XCTAssertFalse(guide.contains("Seer"), "no Seer words to copy into another app")
    }

    /// The call as a host makes it: JSON in, the host's folder filled, JSON out naming the files.
    func testACallThroughTheRosterWritesTheFilesItNames() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: [
            "mappings": ["note: Entry title=headline body=text category=mood date=writtenAt new=Entry()"],
            "directory": folder.path,
        ])
        let answer = try await AnyAgentPackage(NotesAgent.self).perform(input, host: AgentHost(directory: folder.path, ask: "a notes library"))
        let result = try JSONDecoder().decode(NotesResult.self, from: answer)
        let kit = folder.appendingPathComponent("Components/Notes").path
        XCTAssertEqual(result.path, result.paths.first)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(kit + "/"), path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), path)
        }
        let names = Set(result.paths.map { URL(fileURLWithPath: $0).lastPathComponent })
        for name in ["NotesLibrary.swift", "NoteEditor.swift", "NoteCard.swift", "NotesFormatSheet.swift", "NotesLook.swift",
                     "NotesCategories.swift", "NotesLaunch.swift", "NotesProtocols.swift", "Entry+Note.swift"] {
            XCTAssertTrue(names.contains(name), name)
        }
        XCTAssertEqual(result.conformances, ["Entry: note"])
        XCTAssertEqual(result.views.first, "NotesLibrary")
        XCTAssertEqual(result.roots.count, 1)
        XCTAssertTrue(result.roots[0].hasPrefix("NotesLibrary(notes: [Entry]"), result.roots[0])
        XCTAssertEqual(Set(result.expected.map(\.name)), Set(result.made.map(\.name)), "it made what it was asked for")
    }

    /// A host over the wire may name its folder only in `AgentHost`: every file lands there all the same.
    func testTheHostsFolderIsUsedWhenTheCallNamesNone() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: ["strings": ["library.title = Journal"]])
        let answer = try await AnyAgentPackage(NotesAgent.self).perform(input, host: AgentHost(directory: folder.path))
        let result = try JSONDecoder().decode(NotesResult.self, from: answer)
        XCTAssertFalse(result.paths.isEmpty)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(folder.path + "/"), "\(path) is not under the host's folder")
        }
        XCTAssertTrue(result.roots[0].hasPrefix("NotesLibrary(notes: [NotesEntry]"), result.roots[0])
    }

    /// A refusal comes back as the call's to fix, every reason at once, and nothing is written.
    func testARefusedCallIsTheCallsToFixAndWritesNothing() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: [
            "mappings": ["note Entry title=headline"], "sizes": ["grid.minimum = wide"], "launch": ["note = open"],
        ])
        do {
            _ = try await AnyAgentPackage(NotesAgent.self).perform(input, host: AgentHost(directory: folder.path))
            XCTFail("the call is refused")
        } catch {
            let refusal = try XCTUnwrap(AgentRefusal.of(error), "\(error)")
            XCTAssertEqual(refusal.kind, .call)
            XCTAssertEqual(refusal.reasons.count, 3, refusal.reasons.joined(separator: "\n"))
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), [])
    }
}

/// The files the repository ships beside the code: each says what the code does.
final class ShippedFileTests: XCTestCase {
    /// The input schema is the fields as the model sees them. `NOTES_EXAMPLES=1` writes it again.
    func testTheShippedInputSchemaIsTheFieldsAsTheyAre() throws {
        var properties: [String: Any] = [:]
        for (field, note) in NotesAgent.fields {
            properties[field] = ["into", "prefix"].contains(field)
                ? ["description": note, "type": "string"]
                : ["description": note, "items": ["type": "string"], "type": "array"]
        }
        let schema: [String: Any] = [
            "$id": "https://github.com/rao-craft/NotesAgent/blob/main/Schema/notes.input.schema.json",
            "$schema": "https://json-schema.org/draft/2020-12/schema",
            "description": "Every field a call to notes may give; `directory` is Craft's, never the model's.",
            "properties": properties,
            "required": [String](),
            "title": "What notes takes (craft-agent/1)",
            "type": "object",
        ]
        let files = try Fixture.shipped(schema, at: "Schema/notes.input.schema.json")
        XCTAssertEqual(files.shipped, files.made, "Schema/notes.input.schema.json is the fields: NOTES_EXAMPLES=1 writes it again")
    }

    /// The answer schema names the kinds the agent makes.
    func testTheShippedAnswerSchemaNamesTheKindsItMakes() throws {
        let data = try Data(contentsOf: Fixture.package.appendingPathComponent("Schema/notes.answer.schema.json"))
        let schema = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let properties = try XCTUnwrap(schema["properties"] as? [String: [String: Any]])
        for key in ["made", "expected"] {
            let items = try XCTUnwrap(properties[key]?["items"] as? [String: Any])
            let kind = try XCTUnwrap((items["properties"] as? [String: [String: Any]])?["kind"])
            XCTAssertEqual(kind["enum"] as? [String], NotesAgent.makes.map(\.kind), key)
        }
        for key in ["views", "conformances", "roots", "notes"] { XCTAssertNotNil(properties[key], key) }
    }

    /// `Notes.md` names every field, every role's words, every look role, key and launch state.
    func testTheReferenceListsEveryKey() throws {
        let reference = try String(contentsOf: Fixture.package.appendingPathComponent("Schema/Notes.md"), encoding: .utf8)
        var keys = Array(NotesAgent.fields.keys)
        keys += NoteRole.allCases.flatMap { $0.properties.map(\.key) } + ["id"]
        keys += LookRole.all.map(\.name)
        keys += (WordTable.strings + WordTable.lists + WordTable.symbols + WordTable.sizes + WordTable.motion).map(\.key)
        keys += ["grid", "memories", "categories", "new", "editor"]
        for key in keys { XCTAssertTrue(reference.contains("| `\(key)` |"), "Notes.md lists \(key)") }
        for entry in WordTable.sizes + WordTable.motion + WordTable.symbols {
            XCTAssertTrue(reference.contains("| `\(entry.key)` | `\(entry.value)` |"), "Notes.md gives \(entry.key)'s default")
        }
        XCTAssertTrue(reference.contains(NotesBuildTests.pageBody), "Notes.md gives the page body")
    }

    /// The answer shipped for the Seer call is the one the Seer call answers, its paths relative to the project.
    /// `NOTES_EXAMPLES=1` writes it again.
    func testTheShippedSeerAnswerIsTheSeerCallsAnswer() async throws {
        let folder = try Fixture.folder()
        try Fixture.write(Fixture.seerKitPackage, to: folder.appendingPathComponent("Packages/SeerKit/Package.swift"))
        try Fixture.write(Fixture.seerKitNote, to: folder.appendingPathComponent("Packages/SeerKit/Sources/SeerKit/Note.swift"))
        let call = try Data(contentsOf: Fixture.package.appendingPathComponent("Schema/examples/seer.json"))
        let answer = try await AnyAgentPackage(NotesAgent.self).perform(call, host: AgentHost(directory: folder.path))
        let relative = String(decoding: answer, as: UTF8.self)
            .replacingOccurrences(of: folder.path.replacingOccurrences(of: "/", with: "\\/") + "\\/", with: "")
            .replacingOccurrences(of: folder.path + "/", with: "")
        XCTAssertFalse(relative.contains(folder.path), "no absolute path")
        let object = try JSONSerialization.jsonObject(with: Data(relative.utf8))
        let files = try Fixture.shipped(object, at: "Schema/examples/seer.answer.json")
        XCTAssertEqual(files.shipped, files.made, "Schema/examples/seer.answer.json is the Seer call's answer: NOTES_EXAMPLES=1 writes it again")
    }
}
