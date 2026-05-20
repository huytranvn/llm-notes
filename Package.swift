// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LLMNotes",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "LLMNotes", targets: ["LLMNotesApp"]),
        .library(name: "LLMNotesKit", targets: ["LLMNotesKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.5.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0"),
    ],
    targets: [
        .target(
            name: "LLMNotesKit",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Splash", package: "Splash"),
            ],
            path: "Sources/LLMNotesKit"
        ),
        .executableTarget(
            name: "LLMNotesApp",
            dependencies: ["LLMNotesKit"],
            path: "Sources/LLMNotesApp"
        ),
        .testTarget(
            name: "LLMNotesTests",
            dependencies: ["LLMNotesKit"]
        ),
    ]
)
