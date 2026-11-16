import Foundation

/// The apps the gated build writes the kit into: Seer (Swift 6), with stand-ins for SeerKit's `Note`, DesignAgent's
/// names and the services its page body calls, and a journal (Swift 5) made from the second example with a prefix.
enum NotesApps {
    /// DesignAgent's names, as the Seer call's `look` lines read them.
    static let design = """
        import SwiftUI

        extension Color {
            static var accent: Color { Color(red: 0.682, green: 0.565, blue: 0.376) }
            static var background: Color { Color(white: 0.98) }
            static var secondaryBackground: Color { Color(white: 0.94) }
            static var foreground: Color { Color.primary }
            static var secondaryForeground: Color { Color.secondary }
            static var separator: Color { Color.gray.opacity(0.3) }
        }

        extension Font {
            static var brandTitle: Font { Font.system(size: 24, weight: .regular, design: .serif) }
            static var brandBody: Font { Font.system(size: 20, weight: .regular, design: .serif) }
            static var brandBody2: Font { Font.system(size: 18, weight: .regular, design: .serif) }
            static var brandNote: Font { Font.system(size: 18, weight: .light, design: .serif) }
            static var brandNote2: Font { Font.system(size: 16, weight: .light, design: .serif) }
        }

        extension CGFloat {
            static var layer1: CGFloat { 4 }
            static var layer2: CGFloat { 8 }
            static var layer3: CGFloat { 12 }
            static var layer4: CGFloat { 16 }
            static var layer5: CGFloat { 24 }
            static var layer6: CGFloat { 32 }
            static var layer7: CGFloat { 42 }
        }
        """

    /// The relays Seer's page reads, standing in for its Granite services: the library's notes and the events the
    /// page body calls, the layout's sheet, the modals' toast.
    static let services = """
        import Foundation
        import SeerKit

        @MainActor final class LibraryService {
            struct State {
                var notes: [Note] = []
            }

            private(set) var state = State()

            init(notes: [Note] = []) {
                state.notes = notes
            }

            func load() async throws {}

            func save(note: Note) async throws {
                state.notes = [note] + state.notes.filter { $0.id != note.id }
            }

            func delete(note: Note) async throws {
                state.notes = state.notes.filter { $0.id != note.id }
            }
        }

        @MainActor final class LayoutService {
            enum Destination {
                case about
            }

            private(set) var presented: Destination?

            func present(_ destination: Destination) {
                presented = destination
            }
        }

        @MainActor final class ModalService {
            enum Style {
                case success
            }

            private(set) var toasts: [String] = []

            func toast(_ text: String, style: Style) {
                toasts.append(text)
            }
        }
        """

    /// Seer's library page: the body the one-shot prompt gives, written as given.
    static let page = """
        import SwiftUI
        import SeerKit

        struct LibraryPage: View {
            let library: LibraryService
            let layout: LayoutService
            let modals: ModalService

            var body: some View {
                __BODY__
            }
        }
        """

    /// The kit drawn offscreen with Seer's notes, through the page: what proves nothing traps, and pictures to set
    /// beside the reference shots when a folder is given.
    static let seerCheck = #"""
        import SwiftUI
        import ImageIO
        import UniformTypeIdentifiers
        import SeerKit

        public enum SeerCheck {
            static let notes: [Note] = [
                Note(id: "space-001", title: "space-001", body: "Mars is the fourth planet from the Sun and the second-smallest planet in the Solar System. It has a thin atmosphere composed mostly of carbon dioxide.", category: "Space", createdAt: Date(timeIntervalSince1970: 1_794_441_600)),
                Note(id: "space-002", title: "space-002", body: "The Perseverance rover landed on Mars in February 2021, carrying a small helicopter called Ingenuity.", category: "Space", createdAt: Date(timeIntervalSince1970: 1_794_355_200)),
                Note(id: "space-003", title: "space-003", body: "The James Webb Space Telescope observes the universe in infrared light.", category: "Space", createdAt: Date(timeIntervalSince1970: 1_794_268_800)),
                Note(id: "cook-001", title: "cook-001", body: "Bread rises because yeast turns sugars into carbon dioxide.", category: "Cooking", createdAt: Date(timeIntervalSince1970: 1_794_182_400)),
                Note(id: "memory-001", title: "memory-001", body: "A walk by the sea, the light going gold.", category: "Memory", createdAt: Date(timeIntervalSince1970: 1_794_441_600)),
            ]

            @MainActor
            public static func run(into folder: URL?) -> (drawn: [String], failed: [String]) {
                var drawn: [String] = [], failed: [String] = []
                func draw<Content: View>(_ name: String, height: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
                    for scheme in [ColorScheme.light, .dark] {
                        let view = content()
                            .frame(width: 390, height: height)
                            .background(scheme == .dark ? Color.black : Color.white)
                            .environment(\.colorScheme, scheme)
                        let renderer = ImageRenderer(content: view)
                        renderer.scale = 2
                        guard let image = renderer.cgImage else { failed.append(name); continue }
                        let file = "\(name)-\(scheme == .dark ? "dark" : "light")"
                        drawn.append(file)
                        guard let folder,
                              let destination = CGImageDestinationCreateWithURL(folder.appendingPathComponent(file + ".png") as CFURL,
                                                                                UTType.png.identifier as CFString, 1, nil) else { continue }
                        CGImageDestinationAddImage(destination, image, nil)
                        CGImageDestinationFinalize(destination)
                    }
                }

                let shelf = [NotesCategories.general] + NotesCategories.listed
                let grid = notes.filter { !(NotesCategories.memory?.holds($0.category) ?? false) }
                draw("library", height: 844) {
                    NavigationStack {
                        LibraryPage(library: LibraryService(notes: notes), layout: LayoutService(), modals: ModalService())
                    }
                }
                draw("library-empty", height: 844) {
                    NavigationStack {
                        LibraryPage(library: LibraryService(), layout: LayoutService(), modals: ModalService())
                    }
                }
                draw("cards") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
                        ForEach(grid) { note in
                            NoteCard(title: note.noteTitle, date: note.noteDate, text: String(note.noteBody.characters),
                                     category: NotesCategory.resolve(note.noteCategory, in: shelf))
                                .padding(.horizontal, 4)
                                .padding(.bottom, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                if let memory = NotesCategories.memory {
                    draw("memory-card") {
                        NoteCard(title: notes[4].title, date: notes[4].createdAt, text: notes[4].body, category: memory, showsTitle: false)
                            .frame(width: 175)
                            .padding()
                    }
                }
                draw("note", height: 844) {
                    NavigationStack {
                        NoteEditor(note: notes[0], creating: false, categories: shelf, save: { _ in }, delete: { _ in })
                    }
                }
                if let new = Note.notesNew {
                    draw("note-new", height: 844) {
                        NavigationStack {
                            NoteEditor(note: new, creating: true, categories: shelf, save: { _ in })
                        }
                    }
                }
                draw("empty", height: 600) { NotesEmptyList(create: {}) }
                draw("no-results", height: 600) { NotesNoResults() }
                draw("picker", height: 600) {
                    NotesCategoryPicker(categories: shelf, selected: "Space", choose: { _ in }, save: { _, _ in }, delete: { _ in })
                }
                draw("filing", height: 600) {
                    NotesCategoryFiling(categories: shelf, current: "Space", file: { _ in }, create: { _ in })
                }
                draw("category", height: 600) {
                    NotesCategoryEditor(category: shelf[1], creating: false, save: { _ in }, delete: { _ in })
                }
                draw("format", height: 700) { NotesFormatSheet(model: NotesTextModel()) }
                draw("bar") { NotesFormattingBar(model: NotesTextModel(editing: true)) }
                draw("preview") {
                    NoteCardPreview(title: notes[0].title, text: notes[0].body)
                }
                return (drawn, failed)
            }
        }
        """#

    /// The journal's own types, written after its call so the call takes the mapping as written.
    static let journalModels = """
        import SwiftUI

        struct Entry: Identifiable {
            var id = UUID()
            var headline = ""
            var text = AttributedString()
            var mood = ""
            var writtenAt = Date()

            init() {}

            init(headline: String, text: String, mood: String, writtenAt: Date) {
                self.headline = headline
                self.text = AttributedString(text)
                self.mood = mood
                self.writtenAt = writtenAt
            }
        }

        struct Mood {
            var name: String
            var tint: Color
        }
        """

    /// The journal's page: its entries and moods, kept in state.
    static let journalPage = """
        import SwiftUI

        struct JournalPage: View {
            @State private var entries = [Entry(headline: "Monday", text: "A long walk by the river.", mood: "Calm", writtenAt: Date())]
            private let moods = [Mood(name: "Calm", tint: .teal), Mood(name: "Happy", tint: .yellow)]

            var body: some View {
                NavigationStack {
                    KitNotesLibrary(notes: entries, categories: moods, save: { entry in
                        entries = [entry] + entries.filter { $0.id != entry.id }
                    }, delete: { entry in
                        entries.removeAll { $0.id == entry.id }
                    }, toast: { _ in })
                }
            }
        }
        """

    static let checkMain = #"""
        import Foundation
        import Seer

        let folder = ProcessInfo.processInfo.environment["NOTES_SHOTS"].map { URL(fileURLWithPath: $0, isDirectory: true) }
        if let folder { try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true) }
        let result = MainActor.assumeIsolated { SeerCheck.run(into: folder) }
        print("drew \(result.drawn.count) views")
        if !result.failed.isEmpty {
            print("did not draw: \(result.failed)")
            exit(1)
        }
        """#

    static let package = """
        // swift-tools-version:6.0
        import PackageDescription
        let package = Package(
            name: "NotesApps",
            platforms: [.iOS(.v17), .macOS(.v14)],
            products: [.library(name: "NotesApps", targets: ["Seer", "Journal"])],
            targets: [
                .target(name: "SeerKit", swiftSettings: [.swiftLanguageMode(.v6)]),
                .target(name: "Seer", dependencies: ["SeerKit"], swiftSettings: [.swiftLanguageMode(.v6)]),
                .target(name: "Journal", swiftSettings: [.swiftLanguageMode(.v5)]),
                .executableTarget(name: "Check", dependencies: ["Seer"], swiftSettings: [.swiftLanguageMode(.v6)]),
            ]
        )
        """
}
