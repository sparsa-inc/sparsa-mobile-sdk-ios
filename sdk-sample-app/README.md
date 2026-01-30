# Sparsa iOS Sample App

A sample application demonstrating how to integrate and use the Sparsa iOS SDK.

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### 1. Open the Project

```bash
open SampleApp.xcodeproj
```

### 2. Add the SDK

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/sparsa-inc/sparsa-mobile-sdk-ios
   ```
3. Select the version rule (e.g., "Up to Next Major Version")
4. Click **Add Package** and select **SparsaSDK**

### 3. Configure Push Notifications (Optional)

To test push notifications:

1. Replace the placeholder values in `GoogleService-Info.plist` with your Firebase project credentials
2. Enable Push Notifications capability in your target's Signing & Capabilities

### 4. Build and Run

Select a physical iOS device (the SDK requires Secure Enclave, which is not available on simulators) and press **Cmd+R**.

## Features Demonstrated

- **SDK Configuration** - Enter your Client ID and Client Secret from the Sparsa Tenant Console
- **Digital Address Import** - Scan a QR code to import a digital address with document and selfie verification
- **Digital Address Recovery** - Recover a digital address with selfie and biometric verification
- **Credential Management** - View and filter issued credentials
- **Device Management** - List and remove linked devices
- **Device Bootstrapping** - Link a new device via QR code
- **Push Notifications** - Receive and handle consent notifications
- **Proof Verification** - Respond to credential verification requests
