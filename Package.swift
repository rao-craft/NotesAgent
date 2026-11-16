// swift-tools-version:6.0
// NotesAgent: a notes library and a rich-text note editor as plain SwiftUI any app that keeps notes can use (a grid of
// note cards, category sheets, an editor with a formatting bar and a Format sheet), written into an app from its own
// types, as a Granite agent package. An app that links it finds the `notes` agent through Granite's roster, with
// nothing listed by hand.

import PackageDescription

let package = Package(
    name: "NotesAgent",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NotesAgent", targets: ["NotesAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/riteshpakala/Granite.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "NotesAgent",
            dependencies: [.product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(
            name: "NotesAgentTests",
            dependencies: ["NotesAgent", .product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
