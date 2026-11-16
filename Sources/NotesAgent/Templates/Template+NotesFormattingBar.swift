extension Template {
    static let notesFormattingBar = ##"""
import SwiftUI

/// The formatting bar over the keyboard while a note's text is edited: undo and redo, the Format sheet, the styles
/// (on a wide screen), the size a step at a time, the alignment (on a wide screen) and a button that drops the
/// keyboard, in primary glyphs on a rounded glass bar; nothing while the text is not edited.
struct NotesFormattingBar: View {
    @ObservedObject var model: NotesTextModel

    @State private var formatting = false
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: {{n:bar.spacing}}) {
                leading
                Spacer()
                trailing
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .dynamicTypeSize(.medium)
        .frame(height: {{n:bar.height}})
        .tint(.primary)
        .frame(height: model.isEditing ? nil : 0)
        .modifier(NotesGlass(radius: {{n:bar.radius}}))
        .padding(.horizontal, {{n:bar.inset}})
        .opacity(model.isEditing ? 1 : 0)
        .padding(.bottom, {{n:bar.inset}})
        .sheet(isPresented: $formatting) {
            NotesFormatSheet(model: model)
                .presentationDetents([.medium, .large])
        }
    }

    /// Whether the screen is wide enough for the styles and the alignment.
    private var wide: Bool {
        #if os(iOS)
        return sizeClass != .compact
        #else
        return true
        #endif
    }

    @ViewBuilder
    private var leading: some View {
        Button {
            model.undo()
        } label: {
            Image(systemName: {{y:format.undo}})
        }
        .disabled(!model.canUndo)
        .accessibilityLabel({{s:format.undo}})

        Button {
            model.redo()
        } label: {
            Image(systemName: {{y:format.redo}})
        }
        .disabled(!model.canRedo)
        .accessibilityLabel({{s:format.redo}})

        Divider()
            .frame(height: {{n:bar.divider}})

        Button {
            formatting = true
        } label: {
            Image(systemName: {{y:format.open}})
                .contentShape(Rectangle())
        }
        .accessibilityLabel({{s:format.title}})

        if wide {
            HStack(spacing: {{n:bar.spacing}}) {
                ForEach(NotesTextStyle.allCases) { style in
                    let on = model.styles.contains(style)
                    Button {
                        model.toggle(style)
                    } label: {
                        Image(systemName: style.symbol)
                            .fontWeight(on ? .bold : .regular)
                    }
                    .foregroundStyle(on ? NotesLook.accent : Color.primary)
                    .accessibilityLabel(style.title)
                }
            }
        }

        HStack(spacing: 4) {
            Button {
                model.step(-{{n:format.step}})
            } label: {
                Image(systemName: {{y:format.smaller}})
            }
            .accessibilityLabel({{s:format.smaller}})

            Text("\(Int(model.fontSize))")
                .monospacedDigit()
                .frame(minWidth: 28)

            Button {
                model.step({{n:format.step}})
            } label: {
                Image(systemName: {{y:format.larger}})
            }
            .accessibilityLabel({{s:format.larger}})
        }
        .font(.callout)
    }

    @ViewBuilder
    private var trailing: some View {
        if wide {
            Picker({{s:format.alignment}}, selection: $model.alignment) {
                ForEach(NotesAlignment.allCases) { alignment in
                    Image(systemName: alignment.symbol)
                        .accessibilityLabel(alignment.title)
                        .tag(alignment)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 160)
        }

        Button {
            model.endEditing()
        } label: {
            Image(systemName: {{y:format.keyboard}})
        }
        .accessibilityLabel({{s:editor.hideKeyboard}})
    }
}

#Preview {
    VStack {
        Spacer()
        NotesFormattingBar(model: NotesTextModel(editing: true))
    }
}
"""##
}
