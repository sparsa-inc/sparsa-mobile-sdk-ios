# Sparsa iOS Sample App

A sample application demonstrating how to integrate and use the Sparsa iOS SDK.

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- **A physical iOS device** — FIDO uses the Secure Enclave, which the Simulator does not provide,
  so registration and authentication only work on a real device.

## Setup

### 1. Open the Project

```bash
open "Sample App.xcodeproj"
```

### 2. Add the SDK

The sample already references **SparsaSDK** via Swift Package Manager. If you need to re-add it:

1. In Xcode, **File > Add Package Dependencies…**
2. Enter `https://github.com/sparsa-inc/sparsa-mobile-sdk-ios`
3. Choose "Up to Next Major Version" and add the **SparsaSDK** product.

Nothing else is required — the SDK's internal dependencies are compiled into the XCFramework, so
your `Package.swift` declares only `SparsaSDK`.

### 3. WebAuthn / FIDO setup (required for authentication)

FIDO identifies your app by its **bundle identifier**. At runtime the SDK derives an origin of the
form:

```
ios:bundle-id:<your bundle identifier>
```

Sparsa must have that value registered, or FIDO registration and authentication will fail with a
`FIDO process failed.` error.

- This sample's bundle identifier is `com.sparsa.inc.ios`, so its origin is
  `ios:bundle-id:com.sparsa.inc.ios`. If you change `PRODUCT_BUNDLE_IDENTIFIER`, the FIDO identity
  changes with it and the new value must be registered.
- Unlike Android, **no signing certificate or keystore is involved** in the FIDO identity — it is
  the bundle identifier alone. A development team / signing certificate is still needed to run on a
  device, but it does not affect the FIDO origin.

Send your bundle identifier to Sparsa to be registered before testing FIDO.

### 4. Signing to run on device

Because a physical device is required, set your development team:

1. Select the target → **Signing & Capabilities**.
2. Choose your **Team**; Xcode manages a provisioning profile automatically.

### 5. Configure Push Notifications (Optional)

To test push notifications, replace the placeholder values in `GoogleService-Info.plist` with your
Firebase project credentials and enable the **Push Notifications** capability on the target.

### 6. Configure and Run

Enter your Client ID and Client Secret (from the Sparsa Tenant Console) in the app, select your
device, and press **Cmd+R**.

## Features Demonstrated

- **SDK Configuration** — Client ID / Client Secret from the Sparsa Tenant Console
- **Digital Address Import** — QR scan with document and selfie verification
- **Digital Address Recovery** — selfie and biometric verification
- **Credential Management** — view and filter issued credentials
- **Device Management** — list and remove linked devices
- **Device Bootstrapping** — link a new device via QR code
- **Push Notifications** — receive and handle consent notifications
- **Proof Verification** — respond to credential verification requests

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `FIDO process failed.` on registration/authentication | This app's origin (`ios:bundle-id:<bundle id>`) is not registered with Sparsa, or you changed the bundle identifier. |
| FIDO fails only in the Simulator | Expected — the Secure Enclave is device-only. Run on a physical device. |
| `Missing package product 'SparsaSDK'` | Re-add the package (step 2); in Xcode, File > Packages > Reset Package Caches. |
| Cannot run on device (signing) | Set a development Team under Signing & Capabilities (step 4). |
