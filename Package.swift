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
    dependencies: [
        .package(url: "https://github.com/pxlshpr/RemoteLogger", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GlassNumPad",
            dependencies: [
                .product(name: "RemoteLogger", package: "RemoteLogger"),
            ]
        ),
    ]
)
