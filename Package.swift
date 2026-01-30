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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.6/SparsaSDK.xcframework.zip",
            checksum: "15a794798cd1997ec6a719fd42228cea561237ea18709f9cd8cc7233b1fbfe70"
        )
    ]
)
