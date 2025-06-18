# Module Sparsa Mobile SDK for IOS

## Overview
The Sparsa Mobile SDK for IOS provides a comprehensive set of tools for integrating Sparsa's identity verification and authentication services into your Android application.
For SDK Developer API refer [here](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/sparsamobile).
## Key Features
- Secure identity verification
- Biometric authentication
- Document scanning and validation
- Real-time verification

## Getting Started

### Prerequisites
- [XCode](https://developer.apple.com/xcode/) with the latest version
- [Swift 5.9](https://www.swift.org/blog/swift-5.9-released/)

### Installation
Add the Sparsa Mobile SDK XCFramework to your project by including it under Genera -> Frameworks, Libraries, and Embedded Content, as Local Package. 

### Basic Usage
Here's a simple example of how to configure the SDK:

```swift
// Initialize the SDK
SparsaMobile.configure(
    url: "BASE_URL",
    clientId: "client_id_generated_in_tenant_console",
    clientSecret: "client_secret_generated_in_tenant_console"
)
```

Where:
- **url** (required): This is the endpoint URL for all API calls.
- **clientId** (required): Client ID generated in tenant console.
- **clientSecret** (required): Secret generated in your tenant console.

### Core Functionality

The SDK provides several key methods for user authentication and identity verification:

1. **User Authentication**:
   ```swift
   func authenticateUser(attributes: String) async throws -> UserAuthenticationModel
   ```
   Imports a digital address using the QR code or AppLink sent with a recovery email.

2. **User Registration**:
   ```swift
   func registerUser(attributes: String) async throws -> UserAuthenticationModel
   ```
   Imports digital address using a QR code or UniversalLink.



For [all functions](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/sparsamobilesdk) refer here.

## Documentation
For detailed documentation, please refer to the specific package documentation:
- [Errors](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/sparsaerror) - Error handling classes
- [Models](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/) - External data models
- [Main SDK class](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/sparsamobilesdk) - Main SDK components
