// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClipboardManager", targets: ["ClipboardManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "ClipboardManager",
            dependencies: ["HotKey"],
            path: "Sources/ClipboardManager",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
