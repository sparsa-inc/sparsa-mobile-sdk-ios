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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.5/SparsaSDK.xcframework.zip",
            checksum: "34932d1bdcfd634195fc86d15e186ddfd5031c2ee53bb9d24a3853c5336ca29f"
        )
    ]
)
