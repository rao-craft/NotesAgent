//  WHAT: A `look` line: a look role and the app's Swift for it, written into `NotesLook` as that role.
//
//            accent = Color.accent
//            title = Font.brandTitle
//            card = Color("cardFill")
//
//        A colour role takes a Color, a font role a Font; `.accent` is read as `Color.accent` or `Font.accent`, by
//        the role.

import Foundation

enum LookLine {
    static func parse(_ line: String) throws -> (role: LookRole, swift: String) {
        let (name, value) = try KeyLine.split(line, example: "accent = Color.accent")
        guard let role = LookRole.named(name) else {
            throw NotesError.line(line, "`\(name)` is not a look role; the roles are " + LookRole.all.map(\.name).joined(separator: ", "))
        }
        guard !value.contains(";"), !value.contains("\n"), balanced(value) else {
            throw NotesError.line(line, "`\(value)` is not one Swift expression: write the app's name for it, like `\(role.kind == .color ? "Color.accent" : "Font.brandTitle")`")
        }
        // A leading dot names a member of the role's type, which a static property's declared type resolves.
        let swift = value.hasPrefix(".") ? role.swiftType + value : value
        return (role, swift)
    }

    private static func balanced(_ text: String) -> Bool {
        var stack: [Character] = [], quoted = false, escaped = false
        let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
        for character in text {
            if quoted {
                if escaped { escaped = false } else if character == "\\" { escaped = true } else if character == "\"" { quoted = false }
                continue
            }
            switch character {
            case "\"": quoted = true
            case "(", "[", "{": stack.append(character)
            case ")", "]", "}":
                guard stack.popLast() == pairs[character] else { return false }
            default: break
            }
        }
        return stack.isEmpty && !quoted
    }
}
