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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.1/SparsaSDK.xcframework.zip",
            checksum: "078780e2ced4e85f9a902053396abdf581d055a16ea48b7841d9dca18f84585c"
        )
    ]
)
