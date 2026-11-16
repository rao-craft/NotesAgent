# Testing NotesAgent

How `notes` is tested: its own suite, and a gated build of real output. Prompts run through
[Craft](https://github.com/riteshpakala/Craft) will be logged here as they are run.

## The suite

```
swift test                                          # the record, the lines, the templates, the files, the roster
NOTES_BUILD=1 swift test --filter NotesBuildTests   # the output built and drawn for real (gated, about a minute)
NOTES_EXAMPLES=1 swift test --filter ShippedFileTests   # writes the input schema and the Seer answer again
```

- **`NotesAgentTests`:** the record is found with nothing listed; the schema a model is shown; the guide teaches the
  mapping line, the root and one call; a call through Granite's roster writes the files it names, in the call's
  folder or the host's; a refused call comes back as the call's to fix, with every reason, and writes nothing.
- **`ShippedFileTests`:** `Schema/notes.input.schema.json` is the fields as the model sees them; the answer schema
  names the kinds it makes; `Schema/Notes.md` lists every field, role word, look role, key and launch state;
  `Schema/examples/seer.answer.json` is what the Seer call answers.
- **`MappingLineTests`, `WordLineTests`, `LookCategoryLaunchLineTests`, `RefusalTests`:** every kind of line, accepted
  and refused, each refusal with its reason; a call with eleven problems refused with all eleven at once.
- **`TemplateTests`:** every placeholder is a key of the tables and every key is named by a template; a `#Preview` in
  every file that draws; each file declares the types and views the plan names, so a prefix reaches every one; no
  Granite import and no global state; every template and every file of the Seer call is tidy.
- **`NotesEmitTests`:** the files and names a call writes; the conformance to SeerKit's `Note`, read and written
  back; the look, the categories and the launch from the call's lines; every `code` item of Seer's scorecard for the
  library; every string the spec quotes for the Library and the note editor; the same bytes on a second run; a prefix
  on every type and file; a field the editor cannot write back, read only and said.
- **`NotesBuildTests`** (gated): the Seer call written into a Swift 6 app beside stand-ins for SeerKit's `Note`,
  DesignAgent's names and the services its page body calls, with that body written as the prompt gives it; the
  journal example written with a prefix into a Swift 5 app. Both built with `swift build` for the Mac with no warning
  in what the kit wrote, every view drawn offscreen with Seer's notes (`NOTES_SHOTS=<folder>` keeps the pictures),
  then built with `xcodebuild` for `generic/platform=iOS Simulator`, with no warning in what the kit wrote.

## Conformance on Seer

The call in `Schema/examples/seer.json` is the one the one-shot Seer prompt carries. Written into a project that
holds SeerKit's `Note` (`id`, `title`, `body`, `category`, `createdAt`), it writes 33 files into `Components/Notes`
and one conformance, with nothing left for the app to do. The page body

```swift
NotesLibrary(notes: library.state.notes, refresh: { try await library.load() }, save: { try await library.save(note: $0) }, delete: { try await library.delete(note: $0) }, about: { layout.present(.about) }, toast: { modals.toast($0, style: .success) })
```

builds with it for the iPhone simulator and the Mac in Swift 6 (`NotesBuildTests`).

Against Seer's scorecard (area `library`), the output matches every `code` item but one: B-library-9, 10, 11, 12,
14, 15, 16 and 17. B-library-13 is the mock notes themselves, which `$mocks` seeds into SeerKit, not this kit. Every
string the spec quotes for the Library and the note editor is in the code, where the screenshots' text is read;
"17 pt" is the Format sheet's `{size} pt` with the note's size in it.

2026-11-15, Seer at `seer` in Sis: suite 38 tests (one gated), gated build green.
