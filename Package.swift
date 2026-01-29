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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.4/SparsaSDK.xcframework.zip",
            checksum: "22cdf91948461a965d230615a53137d8c86f8f94a6073b371c4ceecfe01d1c75"
        )
    ]
)
