//  WHAT: A notes library and a rich-text note editor as a Granite agent package. A call maps the app's note type with
//        one line (`note: Note title=title body=body category=category date=createdAt`) and gives its words, symbols,
//        sizes, timings, look, categories and launch states; the run writes plain SwiftUI views into the folder the call
//        names (the grid of note cards and its bar, the empty states, the category sheets, the editor with its
//        formatting bar and Format sheet), the protocols they read, the conformances that make the app's types
//        those protocols, and answers where, with the root view's initializer.
//  IN:   Input: the folder, the mapping lines, the modules a mapped type lives in, the look, strings, symbols, sizes,
//        motion, categories and launch lines, a prefix for the kit's names.
//  OUT:  NotesResult: the files written, the views, the conformances, the root's initializer, and what the app still
//        has to do.
//  PIN:  NO MODEL. Every file is made from the call, the same way every time; a line that is not understood is
//        refused with its reason, every reason at once, and nothing is written until every problem is fixed and every
//        file parses.
//  PIN:  THE VIEWS NEVER ROUTE. They take values and closures (save, delete, about, toast) and hold no global state;
//        the app keeps its navigation, and the kit presents only its own sheets and its editor's push. A control whose
//        closure is nil is not drawn.

import Foundation
import GraniteAgents

public struct NotesAgent: GraniteAgentPackage {
    public struct Input: Codable, Sendable {
        /// The folder the views go in, relative to the project; `Components/Notes` when left out.
        public var into: String?
        /// A prefix for the kit's types, when the app already has names that clash: `Kit` writes `KitNotesLibrary`.
        public var prefix: String?
        /// One line a role: `note: Note title=title body=body category=category date=createdAt new=Note(…)`.
        public var mappings: [String]?
        /// Modules the conformances import: where a mapped type lives.
        public var imports: [String]?
        /// `role = Swift`: the app's names for the look, like `accent = Color.accent` or `title = Font.brandTitle`.
        public var look: [String]?
        /// `key = text`: any word the views show, like `library.title = Library`.
        public var strings: [String]?
        /// `key = name`: any SF Symbol, like `library.new = plus`.
        public var symbols: [String]?
        /// `key = number`: any size, like `grid.minimum = 160`.
        public var sizes: [String]?
        /// `key = animation` or `key = seconds`: any timing, like `library.filter = .bouncy`.
        public var motion: [String]?
        /// The categories the views start with: `general = General brown`, `memory = Memory green`, `Space brown`.
        public var categories: [String]?
        /// `destination = state`: the state a launch with `-destination <name>` opens in, like `note = editor space-001`.
        public var launch: [String]?
        /// The host's folder.
        public var directory: String?

        public init(into: String? = nil, prefix: String? = nil, mappings: [String]? = nil, imports: [String]? = nil,
                    look: [String]? = nil, strings: [String]? = nil, symbols: [String]? = nil, sizes: [String]? = nil,
                    motion: [String]? = nil, categories: [String]? = nil, launch: [String]? = nil, directory: String? = nil) {
            self.into = into; self.prefix = prefix; self.mappings = mappings; self.imports = imports; self.look = look
            self.strings = strings; self.symbols = symbols; self.sizes = sizes; self.motion = motion
            self.categories = categories; self.launch = launch; self.directory = directory
        }
    }

    public typealias Event = NotesFrame
    public typealias Output = NotesResult
    public typealias Compute = Void

    public static let word = "notes"
    static let defaultFolder = "Components/Notes"
    /// What it makes: reusable views a page shows, and the conformances that make the app's types theirs.
    public static let makes = [
        AgentMake(kind: "view", what: "a notes library and its rich-text editor as reusable SwiftUI views (NotesLibrary, the grid of note cards with its bar, empty states and category sheets, which pushes NoteEditor with its formatting bar and Format sheet); a page shows them with NotesLibrary(notes:…)",
                  into: ["Components/Notes/*"], never: "routes; never a page, a service, a client or a model type"),
        AgentMake(kind: "conformance", what: "the app's own note and category types made the views' types: one extension a mapping line",
                  into: ["Components/Notes/Conformances/*"], never: "a change to the app's types themselves"),
    ]
    public static let summary = "writes a notes library (a grid of note cards with a bar of menu, filter, memories and new note, empty states, and sheets that pick, add, edit and delete categories) and a rich-text note editor (title, attributed text, formatting bar, Format sheet) as plain SwiftUI, made to show the app's own note type from one mapping line."
    public static let fields = [
        "into": "the folder for the views, relative to the project; Components/Notes when left out",
        "prefix": "a prefix for the kit's types when the app already has those names: `Kit` writes KitNotesLibrary",
        "mappings": "one line a role (note, category): `note: Note title=title body=body category=category date=createdAt new=Note(id: UUID().uuidString, title: \"\", body: \"\", category: \"General\", createdAt: Date())`; a bare path is read off the value and written back, anything else is Swift that may name `value`",
        "imports": "modules the conformances import, such as the package a mapped type is declared in",
        "look": "`role = Swift`, the app's names for the look: accent, card, cardShadow, buttonShadow, panel, titleColor, noteColor (colours); title, note, note2, cardTitle, cardDate, cardText, cardCategory, editorTitle (fonts); a role left out keeps the original's value",
        "strings": "`key = text`, any word the views show (`library.title = Library`); `|` between the items of a list key (`editor.titlePlaceholder`); every key has a default",
        "symbols": "`key = name`, any SF Symbol the views draw (`library.new = plus`); every key has a default",
        "sizes": "`key = number`, any size in points, count or fraction (`grid.minimum = 160`, `picker.detent = 0.6`); every key has a default",
        "motion": "`key = animation` (`library.filter = .bouncy`) or `key = seconds` (`editor.deleteDelay = 0.6`); every key has a default",
        "categories": "the categories the views start with: `general = General brown` (where new notes go), `memory = Memory green` (shown only under the memories button; none when left out), then one line a listed one, `Space brown` or `\"Machine Learning\" brown`, and `color = gray` for a new one",
        "launch": "`destination = state` for a launch with `-destination <name>`: grid, memories, categories, new, or editor and a note's id or title (`note = editor space-001`)",
    ]
    public static let guide = """
        Tag notes for an app that keeps notes: a library of note cards in a grid of adaptive columns (title, date, \
        opening lines, category), under a bar of a more menu, a category filter, memories and a new note; empty \
        states; sheets that pick, add, rename, recolour and delete categories and file a note in one; and a \
        rich-text editor (a title, an attributed body, a formatting bar over the keyboard, a Format sheet of styles, \
        size, alignment and colours), pushed from a card or in a sheet for a new note, saved with a toast. It writes \
        plain SwiftUI (iOS 17 and macOS 14, Liquid Glass on iOS 26) into `into` (Components/Notes). One root view, \
        NotesLibrary, sits in the app's navigation stack: `NotesLibrary(notes: library.state.notes, refresh: { try \
        await library.load() }, save: { try await library.save(note: $0) }, delete: { try await \
        library.delete(note: $0) }, about: { layout.present(.about) }, toast: { modals.toast($0, style: .success) })`. \
        A closure left out removes its control. `mappings` make the app's note type the views' note, one line a \
        role: note (title, body, category, date, new) and category (name, color, and id=). A bare path is read off \
        the value and written back when the editor changes it (`date=createdAt`); anything else is Swift that may \
        name `value` and is only read. `new=` is Swift that makes an empty note (without it nothing makes a note). \
        A body may be a String or an AttributedString, a date a Date, an ISO string or seconds; say `id=` only \
        when the type has no `id`; a type from a package needs `imports`. `look` maps the look roles to the app's \
        names (`accent = Color.accent`, `title = Font.brandTitle`). `strings`, `symbols`, `sizes` and `motion` set \
        any word, SF Symbol, size or timing by key (the reference lists every key with its default). `categories` \
        lists the categories the views start with; a note names its category by id or name. `launch` maps a \
        destination to the state it opens in (`library = grid`, `note = editor space-001`), read from the \
        `destination` default that `-destination <name>` sets. Example, a journal: {"mappings": ["note: Entry \
        title=headline body=text category=mood date=writtenAt new=Entry()"], "strings": ["library.title = \
        Journal"], "categories": ["general = Unsorted gray", "Happy yellow", "Calm teal"], "launch": ["journal = \
        grid"]}. A line it cannot read is refused with the reason and nothing is written: fix the line and call \
        again. Not for the app's services, its network client or its model types.
        """

    public static func output(from events: [NotesFrame]) -> NotesResult? { events.compactMap(\.result).last }

    public init() {}

    public func run(_ input: Input, context: Context) -> AsyncThrowingStream<NotesFrame, Error> {
        // The folder is the call's, else the host's (a host over the wire may give it only there), else the
        // process's: never the runner's working folder while the host named one.
        var resolved = input
        if resolved.directory == nil { resolved.directory = context.host.directory }
        let call = resolved
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let result = try Self.write(call, note: context.host.note) { continuation.yield($0) }
                    continuation.yield(.written(result))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// The whole call: the lines read, the kit made, staged, checked and written.
    static func write(_ input: Input, note: @Sendable (String) -> Void, yield: (NotesFrame) -> Void) throws -> NotesResult {
        var problems: [String] = []
        var notes: [String] = []

        // Mappings, each checked against the app's own types when it declares them.
        var mappings: [Mapping] = []
        for line in input.mappings ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do { mappings.append(try MappingLine.parse(line)) } catch { problems.append("mappings \(error)") }
        }
        var roles: Set<NoteRole> = []
        for mapping in mappings where !roles.insert(mapping.role).inserted {
            problems.append("mappings: \(mapping.role.rawValue) is mapped twice: one type a role")
        }
        var imports = (input.imports ?? []).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        for module in imports where !SwiftName.isModuleName(module) {
            problems.append("imports: `\(module)` is not a module name")
        }
        let files = AgentFiles(directory: input.directory)
        let into = input.into?.trimmingCharacters(in: .whitespaces).isEmpty == false ? input.into! : defaultFolder
        let folder = files.resolve(into)
        // The kit's own folder is not the app's: its previews declare a note of their own.
        let app = AppTypes(root: files.root, excluding: folder)
        mappings = mappings.map { checked($0, app: app, imports: &imports, problems: &problems, notes: &notes) }

        // Words, look, categories, launch.
        let words = WordLines.read(strings: input.strings, symbols: input.symbols, sizes: input.sizes, motion: input.motion,
                                   problems: &problems)
        var look: [String: String] = [:]
        for line in input.look ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                let (role, swift) = try LookLine.parse(line)
                if look[role.name] != nil { throw NotesError.line(line, "`\(role.name)` is mapped twice") }
                look[role.name] = swift
            } catch { problems.append("look \(error)") }
        }
        let categories = CategoryLine.read(input.categories, problems: &problems)
        var launches: [(name: String, state: LaunchState)] = []
        for line in input.launch ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                let launch = try LaunchLine.parse(line)
                if launches.contains(where: { $0.name == launch.name }) { throw NotesError.line(line, "`\(launch.name)` is named twice") }
                launches.append(launch)
            } catch { problems.append("launch \(error)") }
        }
        let prefix = (input.prefix ?? "").trimmingCharacters(in: .whitespaces)
        if !prefix.isEmpty, !SwiftName.isTypeName(prefix) {
            problems.append("prefix: `\(prefix)` is not a prefix for type names: UpperCamelCase letters and digits, like `Kit`")
        }
        let conformances = ConformanceEmitter.emit(mappings, imports: imports) { type, path in app.end(of: path, from: type)?.writable }
        guard problems.isEmpty else { throw NotesError.problems(problems) }
        notes += conformances.notes

        // The files: the templates, the three the lines make, and one conformance a mapping line.
        let names = KitPlan.names
        func prefixed(_ text: String) -> String { TemplateRender.prefixing(text, names: names, prefix: prefix) }
        var planned: [(url: URL, text: String)] = []
        for part in KitPlan.parts {
            let text = try TemplateRender.render(part.template, words: words, replacing: ["general": categories.general.name])
            planned.append((folder.appendingPathComponent(prefix + part.name + ".swift"), prefixed(text)))
        }
        planned.append((folder.appendingPathComponent(prefix + "NotesLook.swift"), prefixed(LookEmitter.emit(look))))
        planned.append((folder.appendingPathComponent(prefix + "NotesCategories.swift"), prefixed(CategoriesEmitter.emit(categories))))
        planned.append((folder.appendingPathComponent(prefix + "NotesLaunch.swift"), prefixed(LaunchEmitter.emit(launches))))
        let conformanceFolder = folder.appendingPathComponent("Conformances", isDirectory: true)
        for file in conformances.files {
            planned.append((conformanceFolder.appendingPathComponent(file.name), prefixed(file.text)))
        }
        yield(.read(mappings: mappings.count, files: planned.count))
        note("writing \(planned.count) files into \(files.relative(folder))")

        let noteMapping = mappings.first { $0.role == .note }
        if noteMapping == nil {
            notes.append("No note type is mapped: the views show \(prefix)NotesEntry values, so map the app's note with `note: Note title=title body=body category=category date=createdAt`.")
        } else if noteMapping?.source(of: "new") == nil {
            notes.append("The note line has no `new=`: nothing makes a note (no plus, no \"\(words.strings["library.emptyAction"] ?? "")\"), so add `new=` with Swift that makes an empty one.")
        }
        if launches.isEmpty {
            notes.append("No `launch` line: a launch with `-destination <name>` opens the grid as it is.")
        }

        let existed = Set(planned.map(\.url.path).filter { FileManager.default.fileExists(atPath: $0) })
        let written = try files.write(planned)
        note("wrote \(written.count) files")
        func state(_ path: String) -> AgentMade.State { existed.contains(path) ? .rewritten : .written }
        func file(_ name: String) -> String? { written.first { ($0 as NSString).lastPathComponent == name } }
        let views = KitPlan.views.map { prefix + $0 }
        var expected = views.map { AgentExpected(kind: "view", name: $0) }
        expected += mappings.map { AgentExpected(kind: "conformance", name: $0.type) }
        var made: [AgentMade] = KitPlan.parts.flatMap { part in
            part.views.compactMap { view in file(prefix + part.name + ".swift").map { AgentMade(kind: "view", name: prefix + view, path: $0, state: state($0)) } }
        }
        made += mappings.compactMap { mapping in
            file("\(mapping.fileStem)+\(mapping.role.name).swift").map { AgentMade(kind: "conformance", name: mapping.type, path: $0, state: state($0)) }
        }
        let noteType = noteMapping?.type ?? prefix + "NotesEntry"
        return NotesResult(path: written.first, paths: written, views: views,
                           conformances: mappings.map { "\($0.type): \($0.role.rawValue)" },
                           roots: [KitPlan.initializer(note: noteType, prefix: prefix)], notes: notes,
                           made: made, expected: expected)
    }

    /// A mapping checked against the app's own types: each path in the type's spelling, each field of a type its
    /// reading takes, the type's module imported. A type it does not find is taken as written.
    private static func checked(_ mapping: Mapping, app: AppTypes, imports: inout [String], problems: inout [String],
                                notes: inout [String]) -> Mapping {
        guard let declared = app.types[AppTypes.named(mapping.type)] else { return mapping }
        if let module = declared.module, !imports.contains(module), !mapping.type.hasPrefix(module + ".") {
            imports.append(module)
            notes.append("`\(mapping.type)` is declared in \(module), so the conformances import it.")
        }
        if mapping.role == .note, mapping.id == nil, !declared.fields.isEmpty, declared.field("id") == nil {
            problems.append("mappings: `\(mapping.type)` has no `id`: say `id=` with the field that tells its notes apart, like `id=slug`")
        }
        func fixed(_ source: Mapping.Source, _ word: String, kind: NoteKind?) -> Mapping.Source {
            guard case .path(let path) = source else { return source }
            let (spelled, problem) = app.check(path, from: mapping.type)
            if let problem {
                problems.append("mappings: \(mapping.role.rawValue) \(word)=\(path): \(problem)")
                return source
            }
            if let kind, kind != .new, let end = app.end(of: spelled, from: mapping.type) {
                let written = end.field.type.replacingOccurrences(of: " ", with: "")
                let base = written.hasSuffix("?") || written.hasSuffix("!") ? String(written.dropLast()) : written
                let known = NoteKind.known.contains(base) || app.types[AppTypes.named(base)] != nil || base.hasPrefix("[")
                if known, !kind.takes.contains(base) {
                    problems.append("mappings: \(mapping.role.rawValue) \(word)=\(path): `\(spelled)` is `\(written)`, and `\(word)` shows \(kind.takesInWords): map a field of one of those, or leave `\(word)` out")
                    return source
                }
            }
            if spelled != path { notes.append("\(mapping.role.rawValue) \(word): `\(path)` is `\(spelled)` on \(declared.name).") }
            return .path(spelled)
        }
        return Mapping(line: mapping.line, role: mapping.role, type: mapping.type,
                       id: mapping.id.map { fixed($0, "id", kind: nil) },
                       assignments: mapping.assignments.map { .init(property: $0.property, source: fixed($0.source, $0.property.key, kind: $0.property.kind)) })
    }
}
