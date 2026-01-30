# Sparsa SDK - iOS

The Sparsa SDK for iOS provides a native interface for managing digital identities, credentials, devices, and authentication flows on the Sparsa platform.

This repository also includes a [sample application](./sdk-sample-app/) demonstrating SDK integration.

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
5. Select **SparsaSDK** and add it to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios", from: "1.1.7")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SparsaSDK"]
)
```

### Manual Installation (XCFramework)

Download the latest XCFramework from the [Releases](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases) page.

1. Download `SparsaSDK.xcframework.zip` from the latest release
2. Unzip the downloaded file
3. Drag and drop `SparsaSDK.xcframework` into your Xcode project
4. Make sure "Copy items if needed" is checked
5. In your target's "Frameworks, Libraries, and Embedded Content" section, ensure SparsaSDK.xcframework is set to "Embed & Sign"

## Quick Start

### 1. Import the SDK

```swift
import SparsaSDK
```

### 2. Configure

Before using any SDK functionality, configure it with your tenant credentials:

```swift
try await Sparsa.shared.configure(
    url: "https://api.<environment>.sparsainc.com",
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    onDelete: {
        // Handle device removal from digital address
    }
)
```

### 3. Import a Digital Address

```swift
let auth = try await Sparsa.shared.importDigitalAddress(attributesJson)
print(auth.digitalAddress)
```

## API Overview

All methods are available as both `async/await` and completion-handler variants.

### Configuration

| Method | Description |
|--------|-------------|
| `configure(url:clientId:clientSecret:onDelete:)` | Initialize the SDK with tenant credentials. |

### Digital Address

| Method | Description |
|--------|-------------|
| `importDigitalAddress(_:)` | Import an existing digital address onto this device. |
| `recoverDigitalAddress(_:)` | Recover a digital address via the recovery flow. |
| `updateDigitalAddress(_:)` | Update the current digital address. |
| `getDigitalAddress()` | Retrieve the current digital address. |

### Credentials

| Method | Description |
|--------|-------------|
| `getCredentials()` | Fetch all credentials. |
| `getCredentials(with:and:)` | Fetch credentials filtered by status and type. |
| `getCredentialDetails(identifier:)` | Get full details of a specific credential. |
| `proofProcess(_:)` | Initiate a credential verification (proof) process. |

### Devices

| Method | Description |
|--------|-------------|
| `getDevices()` | List all devices linked to the digital address. |
| `deleteDevice(deviceIdentifier:)` | Remove a device from the digital address. |
| `deviceBootstrappingVerification(onBootstrappingData:)` | Link a new device via QR-based bootstrapping. |

### Push Notifications

| Method | Description |
|--------|-------------|
| `handleNotification(_:onDelete:onError:)` | Process an incoming push notification. |
| `updateDeviceToken(token:)` | Register a push notification token (String). |
| `updateDeviceToken(_:)` | Register an APNS device token (Data). |

### Localization & Recovery

| Method | Description |
|--------|-------------|
| `getLanguage()` | Get the current SDK language. |
| `setLanguage(language:)` | Set the SDK language. |
| `sendRecoveryEmail(email:)` | Send a recovery email. |
| `setRecoveryEmail(email:)` | Set a new recovery email. |

## Sample App

The [sdk-sample-app](./sdk-sample-app/) directory contains a fully working iOS application that demonstrates:

- SDK configuration and initialization
- Digital address import and recovery
- Credential listing and detail viewing
- Device management
- Push notification handling
- Device bootstrapping via QR code

See the [sample app README](./sdk-sample-app/README.md) for setup instructions.

## License

This SDK is proprietary software. Please contact the vendor for licensing information.
