# SparsaMobile SDK - Sample App

This repository contains a sample iOS application demonstrating how to integrate and use the SparsaMobile SDK.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Download the XCFramework

Download the latest XCFramework from the [Releases](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases) page.

1. Download `SparsaMobile.xcframework.zip` from the latest release
2. Unzip the downloaded file
3. Drag and drop `SparsaMobile.xcframework` into your Xcode project
4. Make sure "Copy items if needed" is checked
5. In your target's "Frameworks, Libraries, and Embedded Content" section, ensure SparsaMobile.xcframework is set to "Embed & Sign"

### Try the Sample App

For a complete working example, see the [sample app](./sdk-sample-app/README.md) included in this repository.

## Quick Start

1. Download and add the SparsaMobile XCFramework to your project (see Installation above)
2. Import the module in your code:
   ```
   import SparsaMobile
   ```
3. Configure the SDK:
   ```
   Task {
       do {
           try await Sparsa.configure(
               url: "BASE_URL",
               clientId: "your-client-id",
               clientSecret: "your-client-secret"
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

For detailed documentation on how to use the SparsaMobile SDK, please refer to the [official documentation](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation).

## License

This SDK is proprietary software. Please contact the vendor for licensing information.