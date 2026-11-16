extension Template {
    static let notesCategoryPicker = ##"""
import SwiftUI

/// The category sheet: two columns of category buttons; a choice filters the grid and closes the sheet, and the
/// floating button clears the filter. With `save`, "Edit" turns the buttons into editors and the floating button into
/// a round plus that adds one.
struct NotesCategoryPicker: View {
    let categories: [NotesCategory]
    /// The id of the category the grid shows; nil for every note.
    let selected: String?
    /// The category chosen, or nil for every note.
    let choose: (NotesCategory?) -> Void
    /// Keeps a category made or edited here (true when it is new); without it there is no "Edit".
    var save: ((NotesCategory, Bool) -> Void)?
    /// Deletes a category; without it the editor shows no delete.
    var delete: ((NotesCategory) -> Void)?

    @State private var editing = false
    @State private var edited: NotesCategory?
    @State private var made: NotesCategory?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            grid
                .modifier(NotesInlineTitle(title: editing ? {{s:picker.editingTitle}} : {{s:picker.title}}))
                .toolbar {
                    if save != nil {
                        ToolbarItem(placement: NotesPlatform.leading) {
                            Button(editing ? {{s:picker.done}} : {{s:picker.edit}}) {
                                NotesHaptics.light()
                                withAnimation({{m:picker.edit}}) {
                                    editing.toggle()
                                }
                            }
                        }
                    }

                    ToolbarItem(placement: NotesPlatform.trailing) {
                        NotesDismissButton()
                    }
                }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationDetents([.fraction({{n:picker.detent}})])
        .sheet(item: $edited) { category in
            NotesCategoryEditor(category: category, creating: false, save: { save?($0, false) }, delete: delete)
        }
        .sheet(item: $made) { category in
            NotesCategoryEditor(category: category, creating: true, save: { save?($0, true) })
        }
    }

    private var grid: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: {{n:picker.minimum}}))]) {
                    ForEach(categories) { category in
                        NotesCategoryButton(
                            category: category,
                            selected: category.id == selected,
                            mark: editing ? .edit : .select,
                            disabled: editing && category.id == NotesCategories.general.id
                        ) {
                            pick(category)
                        }
                        .contextMenu {
                            Button(category.id == selected ? {{s:picker.unselect}} : {{s:picker.select}},
                                   systemImage: category.id == selected ? {{y:picker.unselect}} : {{y:picker.select}}) {
                                withAnimation({{m:library.filter}}) {
                                    choose(category.id == selected ? nil : category)
                                }
                            }
                            if save != nil, category.id != NotesCategories.general.id {
                                Button({{s:picker.editCategory}}, systemImage: {{y:picker.editCategory}}) {
                                    edited = category
                                }
                            }
                        }
                        .padding(4)
                    }
                }
                .padding(.top, 4)
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .overlay(alignment: .bottom) {
                NotesBottomBlur()
            }

            VStack {
                Spacer()
                floating
                    .padding()
            }
        }
    }

    @ViewBuilder
    private var floating: some View {
        if editing {
            NotesCircleButton {
                NotesHaptics.light()
                made = NotesCategory(id: "", name: "", color: NotesCategories.unlisted)
            }
        } else {
            NotesMaterialButton(title: {{s:picker.all}}, selected: selected == nil) {
                withAnimation({{m:library.filter}}) {
                    choose(nil)
                }
                NotesHaptics.soft()
                dismiss()
            }
        }
    }

    private func pick(_ category: NotesCategory) {
        if editing {
            edited = category
        } else {
            withAnimation({{m:library.filter}}) {
                choose(category)
            }
            NotesHaptics.soft()
            dismiss()
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NotesCategoryPicker(categories: NotesEntry.sampleCategories, selected: "Work", choose: { _ in },
                                save: { _, _ in }, delete: { _ in })
        }
}
"""##
}
