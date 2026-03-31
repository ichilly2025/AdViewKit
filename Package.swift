// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdViewKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AdViewKit",
            targets: ["AdViewKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AdViewKit",
            path: "AdViewKit.xcframework"
        )
    ]
)
