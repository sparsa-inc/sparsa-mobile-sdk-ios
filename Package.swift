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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.8/SparsaSDK.xcframework.zip",
            checksum: "1264102c6a6e7cd9bb4b468c3385d7896c06829d2dfc957b2577579646e13381"
        )
    ]
)
