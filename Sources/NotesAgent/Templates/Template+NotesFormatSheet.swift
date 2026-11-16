extension Template {
    static let notesFormatSheet = ##"""
import SwiftUI

/// "Format", a form in a sheet over a note's text: the styles as four tiles (the accent on a faint accent when on),
/// the size and a stepper, the alignment as a segmented picker, and the text's and the highlight's colour wells. Each
/// acts on the selection, or on what is typed next.
struct NotesFormatSheet: View {
    @ObservedObject var model: NotesTextModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                styles
                size
                alignment
                colors
            }
            .navigationTitle({{s:format.title}})
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button({{s:format.done}}) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var styles: some View {
        Section({{s:format.style}}) {
            HStack(spacing: 10) {
                ForEach(NotesTextStyle.allCases) { style in
                    let on = model.styles.contains(style)
                    Button {
                        model.toggle(style)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: style.symbol)
                                .font(.title3)
                            Text(style.title)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(on ? NotesLook.accent.opacity(0.2) : NotesPlatform.groupedFill)
                        )
                    }
                    .foregroundStyle(on ? NotesLook.accent : Color.primary)
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var size: some View {
        Section({{s:format.fontSize}}) {
            HStack {
                Text({{s:format.size}}.replacingOccurrences(of: "{size}", with: "\(Int(model.fontSize))"))
                    .monospacedDigit()
                Spacer()
                Stepper(value: $model.fontSize, in: {{n:format.minimum}}...{{n:format.maximum}}, step: {{n:format.step}}) {
                    EmptyView()
                }
            }
        }
    }

    private var alignment: some View {
        Section({{s:format.alignment}}) {
            Picker({{s:format.alignment}}, selection: $model.alignment) {
                ForEach(NotesAlignment.allCases) { alignment in
                    Label(alignment.title, systemImage: alignment.symbol)
                        .tag(alignment)
                }
            }
            .pickerStyle(.segmented)
            .labelStyle(.iconOnly)
        }
    }

    private var colors: some View {
        Section({{s:format.color}}) {
            HStack {
                Text({{s:format.text}})
                Spacer()
                ColorPicker({{s:format.textColor}}, selection: $model.textColor)
                    .labelsHidden()
            }
            HStack {
                Text({{s:format.highlight}})
                Spacer()
                ColorPicker({{s:format.highlightColor}}, selection: $model.highlightColor, supportsOpacity: true)
                    .labelsHidden()
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NotesFormatSheet(model: NotesTextModel())
                .presentationDetents([.medium, .large])
        }
}
"""##
}
