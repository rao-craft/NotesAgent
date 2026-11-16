import Foundation
@testable import NotesAgent

enum Fixture {
    /// A folder of its own for one test, removed with the process's temporary files.
    static func folder() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("notes-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The package's own folder.
    static var package: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
    }

    /// A call in `Schema/examples`.
    static func example(_ name: String) throws -> NotesAgent.Input {
        let url = package.appendingPathComponent("Schema/examples/\(name).json")
        return try JSONDecoder().decode(NotesAgent.Input.self, from: Data(contentsOf: url))
    }

    /// The text of the file `name` among `paths`.
    static func text(_ paths: [String], _ name: String) throws -> String {
        guard let path = paths.first(where: { $0.hasSuffix("/" + name) }) else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSFilePathErrorKey: name])
        }
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    /// Every file of an answer, joined: what the scorecard's code checks read.
    static func all(_ paths: [String]) throws -> String {
        try paths.map { try String(contentsOfFile: $0, encoding: .utf8) }.joined(separator: "\n")
    }

    /// The Seer call written into a folder that holds SeerKit's `Note` as `$network` writes it.
    static func seer(prefix: String? = nil) throws -> (folder: URL, result: NotesResult) {
        let folder = try folder()
        try write(seerKitPackage, to: folder.appendingPathComponent("Packages/SeerKit/Package.swift"))
        try write(seerKitNote, to: folder.appendingPathComponent("Packages/SeerKit/Sources/SeerKit/Note.swift"))
        var input = try example("seer")
        input.directory = folder.path
        input.prefix = prefix
        return (folder, try NotesAgent.write(input, note: { _ in }, yield: { _ in }))
    }

    /// A JSON file the repository ships, made from code: `NOTES_EXAMPLES=1` writes it again; otherwise it is read
    /// back and compared.
    static func shipped(_ object: Any, at path: String) throws -> (shipped: NSDictionary?, made: NSDictionary?) {
        let url = package.appendingPathComponent(path)
        if ProcessInfo.processInfo.environment["NOTES_EXAMPLES"] == "1" {
            let pretty = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
            try (String(decoding: pretty, as: UTF8.self) + "\n").write(to: url, atomically: true, encoding: .utf8)
        }
        let shipped = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        return (shipped as? NSDictionary, object as? NSDictionary)
    }

    static func write(_ text: String, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    static let seerKitPackage = """
        // swift-tools-version:6.0
        import PackageDescription
        let package = Package(name: "SeerKit", products: [.library(name: "SeerKit", targets: ["SeerKit"])],
                              targets: [.target(name: "SeerKit")])
        """

    /// SeerKit's note, as `$network` writes it from `Note "a note in the library": id String, title String,
    /// body String, category String, createdAt Date`.
    static let seerKitNote = """
        import Foundation

        /// a note in the library
        public struct Note: Codable, Hashable, Identifiable, Sendable {
            public var id: String
            public var title: String
            public var body: String
            public var category: String
            public var createdAt: Date

            public init(id: String, title: String, body: String, category: String, createdAt: Date) {
                self.id = id
                self.title = title
                self.body = body
                self.category = category
                self.createdAt = createdAt
            }

            public static let preview = Note(id: "space-001", title: "space-001", body: "Mars is the fourth planet from the Sun.", category: "Space", createdAt: Date(timeIntervalSince1970: 1_794_441_600))
        }
        """
}
