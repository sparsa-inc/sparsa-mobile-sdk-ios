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
            url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases/download/v1.1.1/Sparsa.xcframework.zip",
            checksum: "92b14a95c82329635bc3e12d736f41260164cefd0b697a756e992525da0b297c"
        )
    ]
)
