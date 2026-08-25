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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.4/SparsaSDK.xcframework.zip",
            checksum: "4b4369a255b084144f6a5ddeefa7a34d718db4b4a149b976e2ce7e69df8d7024"
        )
    ]
)
