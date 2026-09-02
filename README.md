# Sparsa SDK - iOS

The Sparsa SDK for iOS provides a native interface for managing digital identities, credentials, devices, and authentication flows on the Sparsa platform.

[API Reference](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsasdk)

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
    .package(url: "https://github.com/sparsa-inc/sparsa-mobile-sdk-ios", from: "1.2.5")
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
    url: "BASE_URL",
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

#### Expected Notification Payload

The SDK expects an APNs payload with the following structure:

```json
{
  "aps": {
    "alert": {
      "body": "Notification title text"
    },
    "data": {
      "notificationType": "<type>",
      "identifier": "<transaction-id>",
      "correlationId": "<correlation-id>"
    }
  }
}
```

#### Notification Types

| Type | `notificationType` Value | Description |
|------|--------------------------|-------------|
| Credential Verification | `CredentialVerification` | Triggers a credential verification (proof) flow. Requires `identifier` pointing to the proof request. |
| Delete Device | `DeleteDevice` | Indicates the current device was removed from the digital address. The SDK checks device status and invokes `onDelete` if the device no longer exists. |
| Information | `Information` | Generic informational notification. No SDK action is taken. |
| Test | `Test` | Test notification. No SDK action is taken. |

#### Payload Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `notificationType` | String | Yes | One of: `CredentialVerification`, `DeleteDevice`, `Information`, `Test`. |
| `identifier` | String | For `CredentialVerification` | The proof request identifier. |
| `correlationId` | String | No | Correlation ID for request tracking. |

#### Integration Example

```swift
// In your AppDelegate or notification handler:
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    Sparsa.shared.handleNotification(notification.request.content.userInfo,
        onDelete: {
            // Device was removed — clear local state, navigate to setup screen
        },
        onError: { error in
            print("Notification error: \(error.localizedDescription)")
        }
    )
    completionHandler([.sound, .badge])
}

// Register device token:
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Sparsa.shared.updateDeviceToken(deviceToken)
}
```

### Localization & Recovery

| Method | Description |
|--------|-------------|
| `getLanguage()` | Get the current SDK language. |
| `setLanguage(language:)` | Set the SDK language. |
| `sendRecoveryEmail(email:)` | Send a recovery email. |
| `setRecoveryEmail(email:)` | Set a new recovery email. |

## App Identity and FIDO Registration

FIDO identifies your app by its **bundle identifier**. At runtime the SDK derives an origin of the
form:

```
ios:bundle-id:<your bundle identifier>
```

Sparsa must have that value registered before FIDO registration or authentication will succeed —
otherwise the ceremony fails with a `FIDO process failed.` error. Send your app's bundle identifier
to Sparsa to be registered.

- **Changing the bundle identifier changes the app's FIDO identity.** A build with a different
  `PRODUCT_BUNDLE_IDENTIFIER` is a different identity and must be registered separately.
- **No signing certificate or keystore is involved** in the FIDO identity — it is the bundle
  identifier alone. (This differs from Android, where the identity is derived from the signing
  certificate.) A development team is still required to run on a device, but it does not affect the
  origin.
- **FIDO requires a physical device.** It uses the Secure Enclave, which the iOS Simulator does not
  provide, so registration and authentication only work on real hardware.

## Documentation

Full API reference is available [here](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsasdk).

## Sample App

For a complete working example, see the [sample app](./sdk-sample-app/) included in this repository.
