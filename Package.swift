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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.0/SparsaSDK.xcframework.zip",
            checksum: "e0736c5b7ceb2f6511bae82a63b5a9348970a0dadab69a4fec0a286d0042c421"
        )
    ]
)
