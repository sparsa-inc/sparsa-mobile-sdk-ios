# Sparsa Sample App

This is a sample iOS application demonstrating how to integrate and use the Sparsa SDK.

## Prerequisites

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

### Option 1: Swift Package Manager (Recommended)

1. Open `sdk-sample-app.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/sparsa-inc/sparsa-mobile-sdk-ios
   ```
4. Select version `1.1.0` or later
5. Click **Add Package**
6. Select **Sparsa** and add it to the `sdk-sample-app` target

### Option 2: Manual XCFramework Integration

#### 1. Download the XCFramework

Download the latest version of `Sparsa.xcframework` from the [GitHub Releases](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases) page.

1. Go to the Releases page
2. Download `Sparsa.xcframework.zip` from the latest release
3. Unzip the downloaded file

#### 2. Add XCFramework to the Project

1. Open `sdk-sample-app.xcodeproj` in Xcode
2. In the Project Navigator, right-click on the `sdk-sample-app` folder
3. Select "Add Files to sdk-sample-app..."
4. Navigate to the unzipped `Sparsa.xcframework` folder
5. Select `Sparsa.xcframework` and click "Add"
6. Make sure "Copy items if needed" is checked

#### 3. Configure Framework Embedding

1. Select the `sdk-sample-app` project in the Project Navigator
2. Select the `sdk-sample-app` target
3. Go to the "General" tab
4. Scroll down to "Frameworks, Libraries, and Embedded Content"
5. Ensure `Sparsa.xcframework` is listed with "Embed & Sign" selected

### Build and Run

1. Select a connected device (simulator not supported)
2. Press `Cmd + B` to build the project
3. Press `Cmd + R` to run the app

## Project Structure

```
sdk-sample-app/
├── sdk-sample-app/
│   ├── AppMain/              # App initialization and configuration
│   ├── ContainerView/        # Main UI and view models
│   ├── Extensions/           # Swift extensions
│   └── Resources/            # Assets and resources
└── sdk-sample-app.xcodeproj
```

## Configuration

Before running the app, you'll need to configure the SDK with your API credentials. Update the configuration in your app initialization code:

```swift
import Sparsa

try await Sparsa.configure(
    url: "BASE_URL",
    clientId: "your-client-id",
    clientSecret: "your-client-secret"
)
```

## Features Demonstrated

- SDK initialization and configuration
- User authentication flows
- Credential management
- Identity verification
- QR code scanning

## Troubleshooting

### Build Errors

If you encounter build errors after adding the SDK:

1. Clean the build folder: `Product > Clean Build Folder` (Cmd + Shift + K)
2. Delete derived data: `~/Library/Developer/Xcode/DerivedData/`
3. Restart Xcode

### Framework Not Found (Manual Integration)

If you see "Framework not found" errors:

1. Verify the XCFramework is properly added in "Frameworks, Libraries, and Embedded Content"
2. Check that the embedding option is set to "Embed & Sign"
3. Verify the XCFramework file exists in your project directory

### SPM Package Resolution Issues

If SPM fails to resolve the package:

1. Go to **File > Packages > Reset Package Caches**
2. Try **File > Packages > Resolve Package Versions**

## Documentation

For detailed API documentation, visit the [official documentation](https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsa).

## Support

For issues and questions, please refer to the main [Sparsa SDK repository](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios).
