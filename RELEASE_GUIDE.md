# Release Guide for SparsaMobile SDK

This guide explains how to build the XCFramework locally and publish releases to GitHub.

## Repository Structure

### On GitHub (Public):
```
sparsa-mobile-sdk-ios/
├── README.md                      ✅ Sample app documentation
├── RELEASE_GUIDE.md              ✅ This guide
├── sdk-sample-app/               ✅ Sample application
│   ├── README.md                 ✅ Setup instructions
│   ├── .gitignore               ✅ Excludes XCFramework
│   └── sdk-sample-app.xcodeproj  ✅ Xcode project
└── .gitignore                    ✅ Excludes SDK source
```

### On Bitbucket (Private):
```
mobile-sdk-ios/
├── SparsaMobile/                 🔒 SDK source code (private)
├── Package.swift                 🔒 SPM configuration
├── build_xcframework.sh          🔒 Build script
├── prepare_release.sh            🔒 Release script
└── (Everything from GitHub)
```

### Not Committed Anywhere:
```
├── XCFramework/                  ❌ Build artifacts (local only)
└── SparsaMobile.xcworkspace/     ❌ Workspace files
```

## Important: Two-Repository Workflow

### Bitbucket (Private)
- Contains SDK source code
- Build scripts remain here
- Your development work happens here
- Push SDK changes to Bitbucket only

### GitHub (Public)
- Contains only the sample app
- No SDK source code
- Users download pre-built XCFramework from Releases
- Update when sample app changes

## Building and Releasing the SDK

### Step 1: Build XCFramework Locally (on Bitbucket repo)

```bash
# In your local Bitbucket repository
./build_xcframework.sh

# This creates: XCFramework/SparsaMobile.xcframework
```

### Step 2: Create Release Package

```bash
# Zip the XCFramework for distribution
cd XCFramework
zip -r SparsaMobile.xcframework.zip SparsaMobile.xcframework
cd ..
```

### Step 3: Update Sample App (if needed)

If you made sample app changes, push to GitHub:

```bash
# Make sure only sample app files are changed
git status

# Commit and push to GitHub
git add sdk-sample-app/ README.md
git commit -m "Update sample app"
git push github develop
```

### Step 4: Create a GitHub Release

**Using GitHub Web Interface:**

1. Go to: https://github.com/sparsa-inc/sparsa-mobile-sdk-ios/releases
2. Click "Create a new release"
3. Create a new tag (e.g., `v1.0.0`)
4. Fill in the release title: "SparsaMobile SDK v1.0.0"
5. Add release notes (see template below)
6. **Important:** Upload `XCFramework/SparsaMobile.xcframework.zip`
7. Click "Publish release"

**Release Notes Template:**
```markdown
## Installation

Download `SparsaMobile.xcframework.zip` and follow the integration instructions in the [README](https://github.com/sparsa-inc/sparsa-mobile-sdk-ios).

## What's Included
- iOS arm64 support
- Secure authentication
- Identity verification
- Credential management

## Documentation
https://sparsa-inc.github.io/sparsa-mobile-sdk-ios/documentation/sparsamobile/sparsamobilesdk/

## Requirements
- iOS 15.0+
- Xcode 15.0+
```

## Ongoing Workflow

### For SDK Updates (Private Bitbucket)

1. Make code changes in `SparsaMobile/` source
2. Test locally
3. Commit to Bitbucket:
   ```bash
   git add SparsaMobile/
   git commit -m "SDK update: [description]"
   git push origin develop
   ```
4. Build new XCFramework locally
5. Upload to GitHub Releases

### For Sample App Updates (Public GitHub)

1. Make changes to `sdk-sample-app/`
2. Commit and push to GitHub only:
   ```bash
   git add sdk-sample-app/ README.md
   git commit -m "Update sample app: [description]"
   git push github develop
   ```
3. No need to rebuild XCFramework if SDK didn't change

## User Workflow (What Users Will Do)

1. Visit your GitHub repository
2. Read the main README.md
3. Click the Releases link
4. Download `SparsaMobile.xcframework.zip`
5. Clone or download the repository for the sample app
6. Follow `sdk-sample-app/README.md` to integrate the XCFramework
7. Build and run

## Important Notes

- **Never commit the XCFramework to git** - it's in .gitignore
- **Always provide XCFramework via Releases** - users download it separately
- **Sample app should build without errors** after users add the XCFramework
- **Keep README instructions up to date** with any structural changes
- **Version your releases** using semantic versioning (e.g., v1.0.0, v1.1.0)

## Troubleshooting

### "Framework not found" errors for users

- Ensure the release has `SparsaMobile.xcframework.zip` uploaded
- Verify download link in README is correct
- Check that README instructions are clear

### Sample app won't build after cloning

- Make sure `.gitignore` properly excludes the XCFramework
- Verify `sdk-sample-app/README.md` instructions are complete
- Test the setup process yourself on a clean clone

### XCFramework accidentally committed

```bash
# Remove from git but keep local file
git rm -r --cached XCFramework/
git commit -m "Remove XCFramework from version control"
git push
```
