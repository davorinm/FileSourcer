// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "FileSourcer",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .plugin(name: "FileSourcer", targets: ["FileSourcer"]),
    ],
    dependencies: [
    ],
    targets: [
        .plugin(name: "FileSourcer",
                capability: .command(
                    intent: .custom(verb: "fileSourcer", description: "Create source file with content of Resources folder"),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command edit source files")
                    ]
                )
            )
    ]
)
