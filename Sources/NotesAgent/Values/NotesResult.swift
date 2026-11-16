import Foundation
import GraniteAgents

/// What a call answers, as `granite-answer/1`: the files written, as absolute paths, the views and conformances, and
/// the root view's initializer as a line, so the host can write the page body that calls it.
public struct NotesResult: AgentAnswer, Equatable {
    /// The first file written.
    public var path: String?
    /// Every file written.
    public var paths: [String]
    /// The views written, by type name: the root first.
    public var views: [String]
    /// One line a mapped type: `Note: note`.
    public var conformances: [String]
    /// Each root view's initializer, as a line, with the app's own type in it: what a page body calls.
    public var roots: [String]
    /// One sentence each: what the call left out or the app still has to do, and why.
    public var notes: [String]
    /// Each view and conformance written.
    public var made: [AgentMade]
    /// The views the kit is built from, and one conformance a mapping line.
    public var expected: [AgentExpected]
    /// What it could only do in part.
    public var problems: [AgentProblem]

    public init(path: String?, paths: [String], views: [String], conformances: [String], roots: [String], notes: [String],
                made: [AgentMade] = [], expected: [AgentExpected] = [], problems: [AgentProblem] = []) {
        self.path = path; self.paths = paths; self.views = views; self.conformances = conformances; self.roots = roots
        self.notes = notes; self.made = made; self.expected = expected; self.problems = problems
    }
}
