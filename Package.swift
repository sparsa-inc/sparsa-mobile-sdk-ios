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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.5/SparsaSDK.xcframework.zip",
            checksum: "71698ff56f63a9cdaf1aa364d2f85682e1a45c6aa5e06029347a13571f789366"
        )
    ]
)
