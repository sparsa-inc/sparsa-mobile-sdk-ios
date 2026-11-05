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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.2.6/SparsaSDK.xcframework.zip",
            checksum: "d85b1cad9886f07efebef62ff62864bbfad99f3142541e0dd5ae4003b93dbdcf"
        )
    ]
)
