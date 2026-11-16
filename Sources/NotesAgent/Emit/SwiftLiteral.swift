//  WHAT: Text as a Swift string literal, the way a person writes one: `"Library"`, `"Are you sure?\nAll notes…"`.

import Foundation

enum SwiftLiteral {
    /// `text` in double quotes, with `\`, `"` and control characters escaped.
    static func string(_ text: String) -> String {
        var out = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\\": out += "\\\\"
            case "\"": out += "\\\""
            case "\n": out += "\\n"
            case "\t": out += "\\t"
            case "\r": out += "\\r"
            default:
                if scalar.value < 0x20 || scalar.value == 0x7F {
                    out += "\\u{\(String(scalar.value, radix: 16))}"
                } else {
                    out.unicodeScalars.append(scalar)
                }
            }
        }
        return out + "\""
    }

    /// `["a", "b"]`.
    static func array(_ items: [String]) -> String {
        "[" + items.map(string).joined(separator: ", ") + "]"
    }
}
