import Foundation

/// What a run says as it goes.
public enum NotesFrame: Sendable {
    /// The call was read: how many mapping lines, and how many files it writes.
    case read(mappings: Int, files: Int)
    /// The files are written.
    case written(NotesResult)

    public var result: NotesResult? {
        if case .written(let result) = self { return result }
        return nil
    }
}
