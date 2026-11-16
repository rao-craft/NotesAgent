extension Template {
    static let notesCategoryEditor = ##"""
import SwiftUI

/// A category's editor, a sheet over a gradient into its colour: its name in a gradient field and a colour well, with
/// "Cancel" and "Save" and, for one that exists, a delete that asks first.
struct NotesCategoryEditor: View {
    @State private var category: NotesCategory
    let creating: Bool
    let save: (NotesCategory) -> Void
    /// Deletes the category; without it there is no delete.
    var delete: ((NotesCategory) -> Void)?

    @State private var confirming = false
    @FocusState private var naming: Bool
    @Environment(\.dismiss) private var dismiss

    init(category: NotesCategory, creating: Bool, save: @escaping (NotesCategory) -> Void, delete: ((NotesCategory) -> Void)? = nil) {
        _category = State(initialValue: category)
        self.creating = creating
        self.save = save
        self.delete = delete
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField({{s:category.namePlaceholder}}, text: $category.name)
                        .modifier(NotesGradientField(start: NotesLook.card.opacity(0.8), end: category.color.opacity(0.8)))
                        .focused($naming)

                    ColorPicker({{s:category.colorLabel}}, selection: $category.color, supportsOpacity: false)
                        .labelsHidden()
                        .padding(.leading)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.trailing)

                Spacer()
            }
            .modifier(NotesInlineTitle(title: creating ? {{s:category.newTitle}} : {{s:category.editTitle}}))
            .presentationDetents([.fraction({{n:category.detent}})])
            .toolbar {
                ToolbarItem(placement: NotesPlatform.leading) {
                    Button({{s:category.cancel}}) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: NotesPlatform.trailing) {
                    if naming {
                        Button {
                            naming = false
                        } label: {
                            Label({{s:category.ok}}, systemImage: {{y:category.ok}})
                                .labelStyle(.iconOnly)
                        }
                    } else {
                        HStack {
                            if !creating, delete != nil {
                                Button({{s:category.delete}}, systemImage: {{y:category.delete}}, role: .destructive) {
                                    confirming = true
                                }
                            }

                            Button({{s:category.save}}) {
                                save(category)
                                dismiss()
                                NotesHaptics.success()
                            }
                        }
                    }
                }
            }
        }
        .presentationBackground(
            LinearGradient(
                stops: [
                    .init(color: NotesLook.panel, location: 0.2),
                    .init(color: category.color, location: 1.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            if creating { naming = true }
        }
        .confirmationDialog({{s:category.deleteTitle}}, isPresented: $confirming) {
            Button(role: .destructive) {
                remove()
            } label: {
                Label({{s:category.deleteConfirm}}, systemImage: {{y:category.delete}})
            }
            Button({{s:category.deleteCancel}}, role: .cancel) {}
        } message: {
            Text({{s:category.deleteMessage}}.replacingOccurrences(of: "{name}", with: category.shownName))
        }
    }

    /// Closes the editor, then deletes the category once the sheet is down.
    private func remove() {
        dismiss()
        let category = category
        let delete = delete
        Task { @MainActor in
            try? await Task.sleep(for: .seconds({{m:category.deleteDelay}}))
            withAnimation({{m:library.delete}}) {
                delete?(category)
            }
        }
    }
}

#Preview {
    NotesCategoryEditor(category: NotesEntry.sampleCategories[1], creating: false, save: { _ in }, delete: { _ in })
}
"""##
}
