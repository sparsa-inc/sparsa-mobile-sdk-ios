# Sparsa SDK - iOS

This repository contains the Sparsa SDK for iOS and a sample application demonstrating its integration.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager (Recommended)

Add Sparsa to your project using Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/sparsa-inc/sparsa-mobile-sdk-ios
   ```
3. Select the version rule (e.g., "Up to Next Major Version")
4. Click **Add Package**
5. Select **Sparsa** and add it to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios", from: "1.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["Sparsa"]
)
```

### Manual Installation (XCFramework)

Download the latest XCFramework from the [Releases](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases) page.

1. Download `Sparsa.xcframework.zip` from the latest release
2. Unzip the downloaded file
3. Drag and drop `Sparsa.xcframework` into your Xcode project
4. Make sure "Copy items if needed" is checked
5. In your target's "Frameworks, Libraries, and Embedded Content" section, ensure Sparsa.xcframework is set to "Embed & Sign"

### Sample App

For a complete working example, see the [sample app](./sdk-sample-app/README.md) included in this repository.

## Quick Start

1. Install the Sparsa SDK using one of the methods above
2. Import the module in your code:
   ```swift
   import SparsaSDK
   ```
3. Configure the SDK:
   ```swift
   Task {
       do {
           try await Sparsa.shared.configure(
               url: "BASE_URL",
               clientId: "your-client-id",
               clientSecret: "your-client-secret",
               onDelete: { }
           )

           // Now you can use the SDK
       } catch {
           print("Error configuring SDK: \(error)")
       }
   }
   ```

## Features

- Secure user authentication
- Digital identity management
- Credential verification
- Device management
- Biometric authentication support

## Documentation

For detailed documentation on how to use the Sparsa SDK, please refer to the [official documentation](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsa).

## License

This SDK is proprietary software. Please contact the vendor for licensing information.
