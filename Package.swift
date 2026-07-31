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
            checksum: "91ea4aff8331491aa2242b55b9f5e181f528dcb6b5a0dc2d8e5162659c4b4dac"
        )
    ]
)
