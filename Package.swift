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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.3/SparsaSDK.xcframework.zip",
            checksum: "4be9716d2415b020ae5f0bc0af100176a093b36c996cf6d1eca5471c3a23f705"
        )
    ]
)
