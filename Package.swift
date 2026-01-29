// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sparsa",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SparsaSDK",
            targets: ["SparsaSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SparsaSDK",
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.2/SparsaSDK.xcframework.zip",
            checksum: "01715be71857d459ccc00f0fe0b4bfa06dd0d6788d1f7efc3bd0d8df258d0907"
        )
    ]
)
