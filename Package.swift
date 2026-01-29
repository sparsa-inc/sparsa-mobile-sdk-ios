// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sparsa",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Sparsa",
            targets: ["Sparsa"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "Sparsa",
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.0/Sparsa.xcframework.zip",
            checksum: "068778698905f9d4fc503144b533760ee35d5f60757aacbf06c0cef4fa65697e"
        )
    ]
)
