# Sparsa iOS Sample App

This sample app demonstrates how to integrate and use the Sparsa iOS SDK.

## For Public Use (SDK Users)

If you want to try this sample app with the published SDK:

### 1. Add the SDK via Swift Package Manager

```swift
// In Xcode: File → Add Package Dependencies
// Add: https://github.com/sparsainc/sparsa-sdk
```

Or add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/sparsainc/sparsa-sdk", from: "1.0.0")
]
```

### 2. Build and Run

```bash
open iosApp.xcodeproj
```

Then press ⌘R to run.

---

## For SDK Development

If you're developing the SDK and want to test changes with this sample app:

### Setup

1. **Clone the full repository** (including the SDK):
   ```bash
   git clone https://github.com/sparsainc/sparsa-sdk
   cd sparsa-sdk
   ```

2. **Run the development setup**:
   ```bash
   ./link-sdk-to-sample.sh
   ```

3. **Open the workspace** (NOT the individual project):
   ```bash
   open SparsaDevelopment.xcworkspace
   ```

4. **Link the SDK** (one-time, choose ONE method):

   **Method A: SPM (Recommended)**
   - File → Add Package Dependencies
   - Click "Add Local..."
   - Select the `ios-sdk` directory

   **Method B: Direct Framework**
   - Select iosApp.xcodeproj → Sparsa target
   - General → Frameworks, Libraries, and Embedded Content
   - Click + → Add Sparsa.framework from the Sparsa project
   - Set to "Embed & Sign"

### Development Workflow

1. **Make changes** to SDK code in `../ios-sdk/SparsaSDK/Sources/`
2. **Build** (⌘B) - Automatically builds SDK + sample app
3. **Run** (⌘R) - Launches app with your SDK changes
4. **Debug** - Set breakpoints in SDK code, they work seamlessly

### How It Works

```
SparsaDevelopment.xcworkspace
├── Sparsa.xcodeproj (SDK)    ← Edit SDK code here
│   └── Builds: Sparsa.framework
└── iosApp.xcodeproj (Sample)  ← Automatically uses above framework
    └── Imports: Sparsa
```

When you build the sample app:
1. Kotlin shared module builds automatically
2. Swift SDK builds with your changes
3. Sample app links to the built framework
4. No manual copying or repackaging needed!

---

## Features Demonstrated

- ✅ SDK Configuration
- ✅ User Registration
- ✅ FIDO Authentication
- ✅ QR Code Scanning
- ✅ Device Management
- ✅ Credential Management

## Requirements

- iOS 14.0+
- Xcode 15.0+
- Swift 5.9+

For SDK development:
- Kotlin 2.0+ (for building shared module)
- Gradle 8.0+

## What's Not Included in Git

This repository does NOT include:
- Built SDK frameworks (`.framework`, `.xcframework`)
- Build artifacts (`build/` directories)
- Compiled Kotlin frameworks

These are built locally when you develop. This keeps the repository clean and small.

## Troubleshooting

### "No such module 'Sparsa'"

**Cause**: SDK not linked to sample app

**Fix**: Follow the "Link the SDK" step above (Method A or B)

### SDK changes not reflected

**Cause**: Stale build cache

**Fix**:
```
Clean Build Folder (⌘⇧K)
Build (⌘B)
Run (⌘R)
```

### "shared.xcframework not found"

**Cause**: Kotlin framework not built

**Fix**:
```bash
cd ../shared
./gradlew :shared:linkReleaseFrameworkIosSimulatorArm64
./gradlew :shared:linkReleaseFrameworkIosArm64
```

Then in Xcode: Clean (⌘⇧K) → Build (⌘B)

## See Also

- [Quick Start Guide](../QUICK_START.md) - Step-by-step setup
- [Development Setup](../DEVELOPMENT_SETUP.md) - Detailed development workflow
- [SDK Documentation](../ios-sdk/README.md) - API reference
