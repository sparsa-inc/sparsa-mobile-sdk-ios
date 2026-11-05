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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.7/SparsaSDK.xcframework.zip",
            checksum: "c22e9c4b928d1d647eb777cb0893bb08b718e87911b94ad8d379ffad463c1bc7"
        )
    ]
)
