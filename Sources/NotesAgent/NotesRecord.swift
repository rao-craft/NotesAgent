import GraniteAgents

/// The notes agent's place in Granite's roster: an app that links this package finds the `notes` agent by this
/// record, with nothing listed by hand.
@used @section("__DATA_CONST,__granite")
let notesRecord: GraniteRoster.Record = { GraniteRoster.record(NotesAgent.self) }
