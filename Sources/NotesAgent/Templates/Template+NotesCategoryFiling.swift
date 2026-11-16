extension Template {
    static let notesCategoryFiling = ##"""
import SwiftUI

/// The sheet that files a note: two columns of category buttons, the note's own ring filled; a tap files it and
/// closes the sheet. Its floating button asks a name for a new category, makes it and files the note in it.
struct NotesCategoryFiling: View {
    let categories: [NotesCategory]
    /// The id of the category the note is in.
    let current: String
    let file: (NotesCategory) -> Void
    /// Makes a category of the name and files the note in it; without it the floating button is not drawn.
    var create: ((String) -> Void)?

    @State private var asking = false
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            grid
                .modifier(NotesInlineTitle(title: {{s:picker.fileTitle}}))
                .toolbar {
                    ToolbarItem(placement: NotesPlatform.trailing) {
                        NotesDismissButton()
                    }
                }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationDetents([.fraction({{n:picker.detent}})])
    }

    private var grid: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: {{n:picker.minimum}}))]) {
                    ForEach(categories) { category in
                        NotesCategoryButton(category: category, selected: category.id == current) {
                            file(category)
                            NotesHaptics.soft()
                            dismiss()
                        }
                        .padding(4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .overlay(alignment: .bottom) {
                NotesBottomBlur()
            }

            if create != nil {
                VStack {
                    Spacer()
                    NotesMaterialButton(title: {{s:picker.fileCreate}}, wide: true) {
                        NotesHaptics.soft()
                        asking = true
                    }
                    .padding()
                }
            }
        }
        .alert({{s:picker.createTitle}}, isPresented: $asking) {
            Group {
                TextField({{s:picker.namePlaceholder}}, text: $name)
                Button({{s:picker.createSave}}) {
                    create?(name)
                    name = ""
                }
                Button({{s:picker.cancel}}, role: .cancel) {}
            }
            .tint(NotesLook.accent)
        } message: {
            Text({{s:picker.createMessage}})
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NotesCategoryFiling(categories: NotesEntry.sampleCategories, current: "Work", file: { _ in }, create: { _ in })
        }
}
"""##
}
