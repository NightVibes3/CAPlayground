// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CAPlayground",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "CAPlaygroundCore",
            targets: ["CAPlaygroundCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "CAPlaygroundCore",
            dependencies: ["ZIPFoundation"],
            path: "CAPlayground",
            sources: [
                "Models",
                "Services",
                "Utilities",
                "ViewModels",
            ]
        ),
        .testTarget(
            name: "CAPlaygroundTests",
            dependencies: ["CAPlaygroundCore"],
            path: "Tests"
        ),
    ]
)
