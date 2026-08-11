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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.2/SparsaSDK.xcframework.zip",
            checksum: "39c13ba060555fc1efc6ce5f21b272c327529cb96ce750f6b99d94321b6408e5"
        )
    ]
)
