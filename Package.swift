// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GlassNumPad",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "GlassNumPad",
            targets: ["GlassNumPad"]
        ),
    ],
    targets: [
        .target(name: "GlassNumPad"),
    ]
)
