// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Convoy",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Convoy",
            targets: ["Convoy"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Convoy",
            path: "Convoy",
            exclude: ["Info.plist", "Resources"]
        ),
    ]
)
