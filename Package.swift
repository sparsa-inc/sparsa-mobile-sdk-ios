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
            checksum: "fcbfc1322e991497ffcca6dfdafd287d68ba6e839c63b49b4380e151aa121921"
        )
    ]
)
