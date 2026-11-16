extension Template {
    static let notesLibrary = ##"""
import SwiftUI

/// The notes library: every note, newest first, in a grid of cards of adaptive columns, under a bar of the more menu
/// and the category filter (leading) and the memories and a new note (trailing); an empty state for no notes and one
/// for a filter with none; the category sheets; a note's editor pushed from its card, and a new note's in a sheet.
/// It sits in the app's navigation stack, whose bar it fills.
///
///     NotesLibrary(notes: library.state.notes,
///                  refresh: { try await library.load() },
///                  save: { try await library.save(note: $0) },
///                  delete: { try await library.delete(note: $0) },
///                  about: { layout.present(.about) },
///                  toast: { modals.toast($0, style: .success) })
struct NotesLibrary<Item: NoteRepresentable>: View {
    let notes: [Item]
    /// The app's categories, listed after the general one in place of the call's.
    var categories: [any NoteCategoryRepresentable]
    /// Asks for the notes: as the grid appears.
    var refresh: (@MainActor () async throws -> Void)?
    /// Keeps a note: a new one, one edited, one filed in another category. Without it nothing makes or files a note.
    var save: (@MainActor (Item) async throws -> Void)?
    /// Deletes a note; without it there is no "Delete".
    var delete: (@MainActor (Item) async throws -> Void)?
    /// The app's about sheet, the more menu's item; without it there is no more menu.
    var about: (@MainActor () -> Void)?
    /// Shows a toast the app draws: "Note created!", "Category created!".
    var toast: (@MainActor (String) -> Void)?
    /// Keeps a category made or edited in the sheets; without it they last as long as the screen.
    var saveCategory: (@MainActor (NotesCategory) async throws -> Void)?
    /// Deletes a category; its notes move to the general one either way.
    var deleteCategory: (@MainActor (NotesCategory) async throws -> Void)?

    /// The categories the sheets list: the general one, the call's (or the app's), then any made here.
    @State private var shelf: [NotesCategory]
    /// The id of the category the grid shows: nil for every note but the memories.
    @State private var selected: String?
    @State private var picking = false
    @State private var draft: Item?
    @State private var filed: Item?
    @State private var opened: Item.ID?
    /// Notes deleted here, gone from the grid at once while the app deletes them.
    @State private var removed: Set<Item.ID> = []
    @State private var launched = false

    init(notes: [Item], categories: [any NoteCategoryRepresentable] = [],
         refresh: (@MainActor () async throws -> Void)? = nil,
         save: (@MainActor (Item) async throws -> Void)? = nil,
         delete: (@MainActor (Item) async throws -> Void)? = nil,
         about: (@MainActor () -> Void)? = nil,
         toast: (@MainActor (String) -> Void)? = nil,
         saveCategory: (@MainActor (NotesCategory) async throws -> Void)? = nil,
         deleteCategory: (@MainActor (NotesCategory) async throws -> Void)? = nil) {
        self.notes = notes
        self.categories = categories
        self.refresh = refresh
        self.save = save
        self.delete = delete
        self.about = about
        self.toast = toast
        self.saveCategory = saveCategory
        self.deleteCategory = deleteCategory
        _shelf = State(initialValue: Self.shelved(categories))
    }

    var body: some View {
        content
            .modifier(NotesInlineTitle(title: memories ? {{s:library.memoriesTitle}} : {{s:library.title}}))
            .toolbar {
                if NotesCategories.memory != nil {
                    ToolbarItem(placement: NotesPlatform.trailing) {
                        memoriesButton
                    }
                }

                if canCreate {
                    ToolbarItem(placement: NotesPlatform.trailing) {
                        Button {
                            startNote()
                        } label: {
                            Label({{s:library.new}}, systemImage: {{y:library.new}})
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }

                if about != nil {
                    ToolbarItem(placement: NotesPlatform.leading) {
                        Menu {
                            Button {
                                about?()
                                NotesHaptics.light()
                            } label: {
                                Label({{s:library.about}}, systemImage: {{y:library.about}})
                            }
                        } label: {
                            Label({{s:library.more}}, systemImage: {{y:library.more}})
                        }
                    }
                }

                ToolbarItem(placement: NotesPlatform.leading) {
                    filterButton
                }
            }
            .sheet(isPresented: $picking) {
                NotesCategoryPicker(
                    categories: shelf,
                    selected: selected,
                    choose: { selected = $0?.id },
                    save: { keepCategory($0, isNew: $1) },
                    delete: { removeCategory($0) }
                )
            }
            .sheet(item: $draft) { note in
                NavigationStack {
                    editor(note, creating: true)
                }
                .interactiveDismissDisabled()
            }
            .sheet(item: $filed) { note in
                NotesCategoryFiling(
                    categories: shelf,
                    current: NotesCategory.resolve(note.noteCategory, in: shelf).id,
                    file: { file(note, in: $0) },
                    create: save == nil ? nil : { name in
                        filed = file(note, in: makeCategory(name))
                    }
                )
            }
            .navigationDestination(item: $opened) { id in
                if let note = notes.first(where: { $0.id == id }) {
                    editor(note, creating: false)
                }
            }
            .task {
                launch()
                try? await refresh?()
                launch()
            }
            .onChange(of: notes.map(\.id)) {
                launch()
            }
            .onChange(of: categories.map { $0.noteCategoryID }) {
                shelf = Self.shelved(categories)
            }
    }

    // MARK: The grid

    @ViewBuilder
    private var content: some View {
        Group {
            if notes.isEmpty {
                NotesEmptyList(create: canCreate ? { startNote() } : nil)
                    .padding(.bottom, {{n:empty.below}})
            } else if shown.isEmpty {
                NotesNoResults()
                    .padding(.bottom, {{n:filtered.below}})
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: {{n:grid.minimum}}))]) {
                        ForEach(shown) { note in
                            card(note)
                        }
                    }
                    .padding(.horizontal, {{n:grid.inset}})
                    .padding(.top, {{n:grid.top}})
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func card(_ note: Item) -> some View {
        Button {
            opened = note.id
            NotesHaptics.light()
        } label: {
            NoteCard(
                title: note.noteTitle,
                date: note.noteDate,
                text: String(note.noteBody.characters),
                category: NotesCategory.resolve(note.noteCategory, in: shelf),
                showsTitle: !isMemory(note),
                badged: isMemory(note) || note.noteCloudOnly
            )
            .padding(.horizontal, {{n:card.inset}})
            .padding(.bottom, {{n:card.below}})
        }
        .contextMenu {
            if save != nil {
                Button {
                    filed = note
                } label: {
                    Label({{s:card.changeCategory}}, systemImage: {{y:card.changeCategory}})
                }
            }
            ShareLink(item: "\(note.noteTitle)\n\(String(note.noteBody.characters))")
            if delete != nil {
                Button(role: .destructive) {
                    withAnimation({{m:library.delete}}) {
                        remove(note)
                    }
                } label: {
                    Label({{s:card.delete}}, systemImage: {{y:card.delete}})
                }
            }
        } preview: {
            NoteCardPreview(title: note.noteTitle, text: String(note.noteBody.characters))
        }
    }

    // MARK: The bar

    private var memoriesButton: some View {
        Button {
            selected = memories ? nil : NotesCategories.memory?.id
            NotesHaptics.light()
        } label: {
            Image(systemName: memories ? {{y:library.memoriesOn}} : {{y:library.memories}})
                .resizable()
                .font(.subheadline)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(memories ? {{s:library.memoriesShown}} : {{s:library.memoriesHidden}})
    }

    private var filterButton: some View {
        Button {
            picking.toggle()
            NotesHaptics.light()
        } label: {
            Image(systemName: selected != nil ? {{y:library.filterOn}} : {{y:library.filter}})
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(selected != nil ? {{s:library.filtered}} : {{s:library.unfiltered}})
    }

    // MARK: Which notes

    /// Whether the grid shows the memories.
    private var memories: Bool {
        selected != nil && selected == NotesCategories.memory?.id
    }

    private var canCreate: Bool {
        save != nil && Item.notesNew != nil
    }

    private func isMemory(_ note: Item) -> Bool {
        NotesCategories.memory?.holds(note.noteCategory) ?? false
    }

    /// The notes the grid shows, newest first (notes of one time keep the order they came in): the memories under
    /// the memories button, the chosen category's under a filter, else every note but the memories.
    private var shown: [Item] {
        notes.enumerated()
            .filter { !removed.contains($0.element.id) }
            .sorted { $0.element.noteDate == $1.element.noteDate ? $0.offset < $1.offset : $0.element.noteDate > $1.element.noteDate }
            .map(\.element)
            .filter { note in
                if memories { return isMemory(note) }
                if isMemory(note) { return false }
                guard let selected else { return true }
                return NotesCategory.resolve(note.noteCategory, in: shelf).id == selected
            }
    }

    // MARK: Notes

    private func editor(_ note: Item, creating: Bool) -> NoteEditor<Item> {
        NoteEditor(
            note: note,
            creating: creating,
            categories: shelf,
            save: save == nil ? nil : { keep($0) },
            delete: delete == nil ? nil : { remove($0) },
            create: save == nil ? nil : { makeCategory($0) },
            toast: toast
        )
    }

    /// A new note in the general category, in its sheet: empty, or with a title and text already written.
    private func startNote(title: String? = nil, body: String? = nil) {
        guard var note = Item.notesNew else { return }
        note.noteCategory = NotesCategories.general.id
        if let title { note.noteTitle = title }
        if let body { note.noteBody = AttributedString(body) }
        draft = note
        NotesHaptics.light()
    }

    private func keep(_ note: Item) {
        guard let save else { return }
        Task { @MainActor in try? await save(note) }
    }

    /// Files a note in a category, keeping its date; the note as filed.
    @discardableResult
    private func file(_ note: Item, in category: NotesCategory) -> Item {
        var moved = note
        moved.noteCategory = category.id
        keep(moved)
        return moved
    }

    private func remove(_ note: Item) {
        removed.insert(note.id)
        guard let delete else { return }
        Task { @MainActor in try? await delete(note) }
    }

    // MARK: Categories

    private static func shelved(_ categories: [any NoteCategoryRepresentable]) -> [NotesCategory] {
        [NotesCategories.general] + (categories.isEmpty ? NotesCategories.listed : categories.map { NotesCategory($0) })
    }

    /// Keeps a category made or edited in the sheets.
    private func keepCategory(_ category: NotesCategory, isNew: Bool) {
        var category = category
        if isNew {
            category.id = category.name.isEmpty ? UUID().uuidString : category.name
            shelf.append(category)
            toast?({{s:toast.categoryCreated}})
        } else if let index = shelf.firstIndex(where: { $0.id == category.id }) {
            shelf[index] = category
        }
        if let saveCategory {
            let kept = category
            Task { @MainActor in try? await saveCategory(kept) }
        }
    }

    /// Makes a category of a name, from a filing sheet's floating button.
    private func makeCategory(_ name: String) -> NotesCategory {
        let category = NotesCategory(id: name.isEmpty ? UUID().uuidString : name, name: name, color: NotesCategories.unlisted)
        withAnimation {
            shelf.append(category)
        }
        NotesHaptics.success()
        toast?({{s:toast.categoryCreated}} + "\n" + {{s:toast.categoryAssigned}})
        if let saveCategory {
            Task { @MainActor in try? await saveCategory(category) }
        }
        return category
    }

    /// Deletes a category: its notes move to the general one.
    private func removeCategory(_ category: NotesCategory) {
        for note in notes where NotesCategory.resolve(note.noteCategory, in: shelf).id == category.id {
            file(note, in: NotesCategories.general)
        }
        shelf.removeAll { $0.id == category.id }
        if selected == category.id { selected = nil }
        if let deleteCategory {
            Task { @MainActor in try? await deleteCategory(category) }
        }
    }

    // MARK: Launch

    /// Opens what the launch names, as if the person had gone there: once, unanimated, as soon as its note is here.
    private func launch() {
        guard !launched, let state = NotesLaunch.current else { return }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        switch state {
        case .grid:
            launched = true
        case .memories:
            launched = true
            selected = NotesCategories.memory?.id
        case .categories:
            launched = true
            withTransaction(transaction) { picking = true }
        case .new:
            launched = true
            withTransaction(transaction) { startNote() }
        case .draft(let title, let body):
            launched = true
            withTransaction(transaction) { startNote(title: title, body: body) }
        case .editor(let target):
            guard let note = notes.first(where: { "\($0.id)" == target }) ?? notes.first(where: { $0.noteTitle == target }) else { return }
            launched = true
            withTransaction(transaction) { opened = note.id }
        }
    }
}

#Preview {
    NavigationStack {
        NotesLibrary(notes: NotesEntry.samples, save: { _ in }, delete: { _ in }, about: {})
    }
}
"""##
}
