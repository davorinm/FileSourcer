// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "FilesSourcer",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .plugin(name: "FilesSourcerPlugin", targets: ["FilesSourcerPlugin"]),
        .library(name: "FilesSourcer", targets: ["FilesSourcer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "FilesSourcer", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
        ]),
        .plugin(name: "FilesSourcerPlugin",
                capability: .command(
                    intent: .custom(verb: "filesSourcer", description: "Create source file with content of Resources folder"),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command edit source files")
                    ]
                )
            )
    ]
)
