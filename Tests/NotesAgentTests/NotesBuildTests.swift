import Foundation
import XCTest
@testable import NotesAgent

/// The kit compiled and drawn as apps would: the Seer call written into Seer (Swift 6) beside stand-ins for SeerKit's
/// `Note`, DesignAgent's names and the services its page body calls, with that body written as the prompt gives it;
/// the journal example written with a prefix into an app in Swift 5. Built with `swift build` for the Mac (no warning
/// in what the kit wrote), every view drawn offscreen, then built with `xcodebuild` for the iPhone simulator.
/// Gated (`NOTES_BUILD=1`): the builds take a few minutes. `NOTES_SHOTS=<folder>` keeps the pictures.
final class NotesBuildTests: XCTestCase {
    /// The page body the one-shot prompt gives the host for `library`.
    static let pageBody = "NotesLibrary(notes: library.state.notes, refresh: { try await library.load() }, save: { try await library.save(note: $0) }, delete: { try await library.delete(note: $0) }, about: { layout.present(.about) }, toast: { modals.toast($0, style: .success) })"

    func testTheSeerCallBuildsForMacAndIPhoneAndEveryViewDraws() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["NOTES_BUILD"] == "1", "set NOTES_BUILD=1 to build the output")
        let package = try Fixture.folder()
        try Fixture.write(NotesApps.package, to: package.appendingPathComponent("Package.swift"))
        try Fixture.write(Fixture.seerKitNote, to: package.appendingPathComponent("Sources/SeerKit/Note.swift"))

        var seer = try Fixture.example("seer")
        seer.into = "Sources/Seer/Components/Notes"
        seer.directory = package.path
        let seerResult = try NotesAgent.write(seer, note: { _ in }, yield: { _ in })
        XCTAssertEqual(seerResult.notes, [])
        var journal = try Fixture.example("journal")
        journal.into = "Sources/Journal/Notes"
        journal.prefix = "Kit"
        journal.directory = package.path
        let journalResult = try NotesAgent.write(journal, note: { _ in }, yield: { _ in })
        XCTAssertTrue(journalResult.roots[0].hasPrefix("KitNotesLibrary(notes: [Entry]"))

        let sources = package.appendingPathComponent("Sources")
        try Fixture.write(NotesApps.design, to: sources.appendingPathComponent("Seer/Design.swift"))
        try Fixture.write(NotesApps.services, to: sources.appendingPathComponent("Seer/Services.swift"))
        try Fixture.write(NotesApps.page.replacingOccurrences(of: "__BODY__", with: Self.pageBody),
                          to: sources.appendingPathComponent("Seer/LibraryPage.swift"))
        try Fixture.write(NotesApps.seerCheck, to: sources.appendingPathComponent("Seer/SeerCheck.swift"))
        try Fixture.write(NotesApps.journalModels, to: sources.appendingPathComponent("Journal/Models.swift"))
        try Fixture.write(NotesApps.journalPage, to: sources.appendingPathComponent("Journal/JournalPage.swift"))
        try Fixture.write(NotesApps.checkMain, to: sources.appendingPathComponent("Check/main.swift"))

        func kitWarnings(_ log: String) -> [Substring] {
            log.split(separator: "\n").filter { ($0.contains("/Components/Notes/") || $0.contains("/Journal/Notes/")) && $0.contains("warning:") }
        }

        // The Mac: Swift 6 and Swift 5, with no warning in what the kit wrote.
        let mac = try run(["swift", "build", "--package-path", package.path])
        XCTAssertEqual(mac.status, 0, String(mac.log.suffix(6_000)))
        let macWarnings = kitWarnings(mac.log)
        XCTAssertTrue(macWarnings.isEmpty, macWarnings.joined(separator: "\n"))

        // Every view drawn with Seer's notes: nothing traps.
        let drawn = try run(["swift", "run", "--package-path", package.path, "Check"])
        XCTAssertEqual(drawn.status, 0, String(drawn.log.suffix(4_000)))
        XCTAssertNotNil(drawn.log.range(of: #"drew \d{2,} views"#, options: .regularExpression), String(drawn.log.suffix(4_000)))

        // The iPhone simulator.
        let phone = try run(["xcodebuild", "-scheme", "NotesApps", "-destination", "generic/platform=iOS Simulator",
                             "-derivedDataPath", package.appendingPathComponent("dd").path,
                             "-skipPackagePluginValidation", "-skipMacroValidation", "build"], in: package)
        XCTAssertTrue(phone.log.contains("** BUILD SUCCEEDED **"), String(phone.log.suffix(6_000)))
        let phoneWarnings = Set(kitWarnings(phone.log))
        XCTAssertTrue(phoneWarnings.isEmpty, phoneWarnings.sorted().joined(separator: "\n"))
    }

    private func run(_ arguments: [String], in folder: URL? = nil) throws -> (status: Int32, log: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        if let folder { process.currentDirectoryURL = folder }
        let out = Pipe()
        process.standardOutput = out
        process.standardError = out
        try process.run()
        let data = out.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }
}
