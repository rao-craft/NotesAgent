//  WHAT: What a role property holds, and how a mapped value becomes it: its Swift type, the `NotesValue` reading a
//        conformance wraps every right side in, and the field types that reading takes.
//  PIN:  EVERY RIGHT SIDE IS CONVERTED. An app's note body may be a String or an AttributedString, its date a Date, an
//        ISO string or seconds; `NotesValue` has an overload for each, so a bare path compiles whatever the field is.

import Foundation

enum NoteKind: Sendable, Equatable {
    case text, rich, date, color, flag, new

    /// The requirement's type in the protocol.
    var swiftType: String {
        switch self {
        case .text: return "String"
        case .rich: return "AttributedString"
        case .date: return "Date"
        case .color: return "Color"
        case .flag: return "Bool"
        case .new: return "Self?"
        }
    }

    /// The `NotesValue` function a mapped value is read through.
    var conversion: String {
        switch self {
        case .text: return "text"
        case .rich: return "rich"
        case .date: return "date"
        case .color: return "color"
        case .flag: return "flag"
        case .new: return ""
        }
    }

    /// The field types the readings of this kind take, optional or not, as `NotesValue` declares them.
    var takes: Set<String> {
        switch self {
        case .text: return ["String", "Substring", "UUID", "Int"]
        case .rich: return ["AttributedString", "String"]
        case .date: return ["Date", "String", "Double", "Int"]
        case .color: return ["Color", "String"]
        case .flag: return ["Bool"]
        case .new: return []
        }
    }

    /// The field types `NotesValue.assign` writes back to: a field of another type is shown and never written.
    var writes: Set<String> {
        switch self {
        case .text, .rich, .date: return takes
        case .color, .flag, .new: return []
        }
    }

    /// What `takes` says, in words, for a refusal.
    var takesInWords: String {
        switch self {
        case .text: return "text (a String, a Substring, a UUID or an Int)"
        case .rich: return "a note's text (an AttributedString or a String)"
        case .date: return "a date (a Date, an ISO String, or seconds as a Double or an Int)"
        case .color: return "a colour (a Color, or a String naming one: `brown`, `#AE9060`)"
        case .flag: return "a Bool (a Bool field, or Swift like `true`)"
        case .new: return "a new value"
        }
    }

    static let known: Set<String> = ["String", "Substring", "UUID", "Int", "Double", "Float", "Bool", "Date", "URL", "Data",
                                     "AttributedString", "Color", "Decimal"]
}
