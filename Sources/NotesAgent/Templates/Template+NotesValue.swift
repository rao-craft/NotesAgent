extension Template {
    static let notesValue = ##"""
import SwiftUI

/// How a mapped field becomes what the notes views show, and how what the editor writes goes back into it: one
/// function a kind of field, so a mapping line compiles whatever type its field is.
enum NotesValue {
    // MARK: Text

    static func text(_ value: String) -> String { value }
    static func text(_ value: String?) -> String { value ?? "" }
    static func text(_ value: Substring) -> String { String(value) }
    static func text(_ value: Substring?) -> String { value.map(String.init) ?? "" }
    static func text(_ value: UUID) -> String { value.uuidString }
    static func text(_ value: UUID?) -> String { value?.uuidString ?? "" }
    static func text(_ value: Int) -> String { String(value) }
    static func text(_ value: Int?) -> String { value.map(String.init) ?? "" }

    // MARK: A note's text

    static func rich(_ value: AttributedString) -> AttributedString { value }
    static func rich(_ value: AttributedString?) -> AttributedString { value ?? AttributedString() }
    static func rich(_ value: String) -> AttributedString { AttributedString(value) }
    static func rich(_ value: String?) -> AttributedString { AttributedString(value ?? "") }

    // MARK: Dates

    static func date(_ value: Date) -> Date { value }
    static func date(_ value: Date?) -> Date { value ?? .distantPast }
    /// An ISO 8601 date, with a time or without one.
    static func date(_ value: String) -> Date {
        if let date = try? Date(value, strategy: .iso8601) { return date }
        if let date = try? Date(value, strategy: Date.ISO8601FormatStyle().year().month().day()) { return date }
        return .distantPast
    }
    static func date(_ value: String?) -> Date { value.map { date($0) } ?? .distantPast }
    /// Seconds since 1970.
    static func date(_ value: Double) -> Date { Date(timeIntervalSince1970: value) }
    static func date(_ value: Double?) -> Date { value.map { Date(timeIntervalSince1970: $0) } ?? .distantPast }
    static func date(_ value: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(value)) }
    static func date(_ value: Int?) -> Date { value.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? .distantPast }

    // MARK: Colours

    static func color(_ value: Color) -> Color { value }
    static func color(_ value: Color?) -> Color { value ?? NotesCategories.unlisted }
    /// A SwiftUI colour's name (`brown`), `accent`, or `#RRGGBB`.
    static func color(_ value: String) -> Color {
        switch value.trimmingCharacters(in: .whitespaces).lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "mint": return .mint
        case "teal": return .teal
        case "cyan": return .cyan
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray", "grey": return .gray
        case "black": return .black
        case "white": return .white
        case "accent": return NotesLook.accent
        case let hex where hex.hasPrefix("#") && hex.count == 7:
            guard let number = UInt32(hex.dropFirst(), radix: 16) else { return NotesCategories.unlisted }
            return Color(red: Double((number >> 16) & 0xFF) / 255, green: Double((number >> 8) & 0xFF) / 255,
                         blue: Double(number & 0xFF) / 255)
        default: return NotesCategories.unlisted
        }
    }
    static func color(_ value: String?) -> Color { value.map { color($0) } ?? NotesCategories.unlisted }

    // MARK: Flags

    static func flag(_ value: Bool) -> Bool { value }
    static func flag(_ value: Bool?) -> Bool { value ?? false }

    // MARK: Writing back

    static func assign(_ value: String, to field: inout String) { field = value }
    static func assign(_ value: String, to field: inout String?) { field = value }
    static func assign(_ value: String, to field: inout Substring) { field = Substring(value) }
    static func assign(_ value: String, to field: inout Substring?) { field = Substring(value) }
    static func assign(_ value: String, to field: inout UUID) { if let id = UUID(uuidString: value) { field = id } }
    static func assign(_ value: String, to field: inout UUID?) { field = UUID(uuidString: value) }
    static func assign(_ value: String, to field: inout Int) { if let number = Int(value) { field = number } }
    static func assign(_ value: String, to field: inout Int?) { field = Int(value) }
    static func assign(_ value: AttributedString, to field: inout AttributedString) { field = value }
    static func assign(_ value: AttributedString, to field: inout AttributedString?) { field = value }
    static func assign(_ value: AttributedString, to field: inout String) { field = String(value.characters) }
    static func assign(_ value: AttributedString, to field: inout String?) { field = String(value.characters) }
    static func assign(_ value: Date, to field: inout Date) { field = value }
    static func assign(_ value: Date, to field: inout Date?) { field = value }
    static func assign(_ value: Date, to field: inout String) { field = value.formatted(.iso8601) }
    static func assign(_ value: Date, to field: inout String?) { field = value.formatted(.iso8601) }
    static func assign(_ value: Date, to field: inout Double) { field = value.timeIntervalSince1970 }
    static func assign(_ value: Date, to field: inout Double?) { field = value.timeIntervalSince1970 }
    static func assign(_ value: Date, to field: inout Int) { field = Int(value.timeIntervalSince1970) }
    static func assign(_ value: Date, to field: inout Int?) { field = Int(value.timeIntervalSince1970) }
}
"""##
}
