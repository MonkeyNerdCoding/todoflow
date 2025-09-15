# TodoFlow Setup Guide

This guide will help you set up and run TodoFlow on your device. Follow the instructions for your operating system and target platform.

## 📋 Prerequisites

### System Requirements

#### For Android Development
- **Operating System**: Windows 10/11, macOS 10.15+, or Ubuntu 18.04+
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 10GB free space
- **Internet**: Required for downloading dependencies

#### For iOS Development (macOS only)
- **Operating System**: macOS 11.0+ (Big Sur or later)
- **Xcode**: Latest version from Mac App Store
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 15GB free space

### Required Software

#### 1. Flutter SDK
**Install Flutter:**

**Windows:**
```powershell
# Using Git
git clone https://github.com/flutter/flutter.git -b stable
# Add Flutter to your PATH environment variable
```

**macOS/Linux:**
```bash
# Using Git
git clone https://github.com/flutter/flutter.git -b stable
# Add to your shell profile (.bashrc, .zshrc)
export PATH="$PATH:`pwd`/flutter/bin"
```

**Verify Installation:**
```bash
flutter doctor
```

#### 2. Development Environment

**Option A: Android Studio (Recommended)**
1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Install Android SDK and Android SDK Command-line Tools
3. Install Flutter and Dart plugins

**Option B: VS Code**
1. Download from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install Flutter extension
3. Install Dart extension

#### 3. Platform-Specific Setup

**Android Setup:**
1. Install Android Studio
2. Configure Android SDK (API level 21+)
3. Create Android Virtual Device (AVD) or connect physical device
4. Enable Developer Options and USB Debugging on physical device

**iOS Setup (macOS only):**
1. Install Xcode from Mac App Store
2. Install Xcode command line tools: `xcode-select --install`
3. Accept Xcode license: `sudo xcodebuild -license`
4. Configure iOS Simulator or connect physical device

#### 4. Git (for cloning repository)
- **Windows**: Download from [git-scm.com](https://git-scm.com/)
- **macOS**: Pre-installed or via Homebrew: `brew install git`
- **Linux**: `sudo apt install git` (Ubuntu/Debian)

## 🚀 Installation Steps

### Step 1: Verify Flutter Installation
```bash
flutter doctor
```
Ensure all checkmarks are green. Address any issues before proceeding.

### Step 2: Clone the Repository
```bash
git clone https://github.com/your-username/todoflow.git
cd todoflow
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Generate Code (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Verify Project Setup
```bash
flutter analyze
```

### Step 6: Run the Application

**For Android:**
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>
```

**For iOS (macOS only):**
```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run

# Run on specific iOS device
flutter run -d <device-id>
```

**For Web (Development):**
```bash
flutter run -d chrome
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the project root (optional):
```env
# App Configuration
APP_ENV=development
DEBUG_MODE=true

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
```

### Build Configurations

**Debug Build (Development):**
```bash
flutter run --debug
```

**Release Build (Production):**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## 📱 Device Setup

### Android Device Setup
1. **Enable Developer Mode:**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Developer Options will appear in Settings

2. **Enable USB Debugging:**
   - Go to Settings > Developer Options
   - Enable "USB Debugging"
   - Connect device via USB and authorize computer

3. **Install APK (Alternative):**
   ```bash
   flutter build apk
   flutter install
   ```

### iOS Device Setup (macOS only)
1. **Connect Device:**
   - Connect iPhone/iPad via USB
   - Trust computer on device

2. **Developer Account:**
   - Sign in with Apple ID in Xcode
   - Select development team for code signing

3. **Run on Device:**
   ```bash
   flutter run
   ```

### Emulator/Simulator Setup

**Android Emulator:**
1. Open Android Studio
2. Go to Tools > AVD Manager
3. Create Virtual Device
4. Choose device definition and system image
5. Start emulator

**iOS Simulator (macOS only):**
1. Open Xcode
2. Go to Window > Devices and Simulators
3. Click "+" to add simulator
4. Or run: `open -a Simulator`

## 🐛 Troubleshooting

### Common Issues

#### Flutter Doctor Issues
**Issue**: Android licenses not accepted
```bash
flutter doctor --android-licenses
# Accept all licenses
```

**Issue**: Xcode installation issues (macOS)
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### Build Issues
**Issue**: Gradle build failure (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Issue**: CocoaPods issues (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

#### Runtime Issues
**Issue**: Hot reload not working
```bash
# Restart with hot reload
r

# Hot restart (full restart)
R

# Quit and restart
q
flutter run
```

**Issue**: Dependencies not found
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Performance Issues
**Issue**: App running slowly
- Use release mode: `flutter run --release`
- Check for memory leaks in provider disposal
- Optimize ListView.builder usage

#### Connection Issues
**Issue**: Device not detected
```bash
# Check connected devices
flutter devices

# Check ADB connection (Android)
adb devices

# Restart ADB
adb kill-server
adb start-server
```

### Platform-Specific Troubleshooting

#### Windows Specific
- **PowerShell Execution Policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Long Path Support**: Enable in Windows Settings
- **Antivirus**: Add Flutter SDK folder to exclusions

#### macOS Specific
- **Gatekeeper Issues**: `sudo spctl --master-disable` (temporary)
- **Xcode Command Line Tools**: `xcode-select --install`
- **Rosetta 2** (Apple Silicon): `softwareupdate --install-rosetta`

#### Linux Specific
- **Missing Dependencies**:
  ```bash
  sudo apt-get update
  sudo apt-get install curl git unzip xz-utils zip libglu1-mesa
  ```

### Getting Help

#### Debug Information Collection
When reporting issues, include:
```bash
# Flutter version and environment
flutter doctor -v

# Project dependencies
flutter pub deps

# Detailed error output
flutter run --verbose
```

#### Useful Commands
```bash
# Clean and rebuild
flutter clean && flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Run tests
flutter test
```

## 🎯 Development Workflow

### Recommended Development Flow
1. **Start Development Server:**
   ```bash
   flutter run
   ```

2. **Hot Reload During Development:**
   - Press `r` for hot reload
   - Press `R` for hot restart
   - Press `q` to quit

3. **Testing Changes:**
   ```bash
   flutter test
   flutter test --coverage
   ```

4. **Code Quality Checks:**
   ```bash
   flutter analyze
   dart format .
   ```

### IDE Configuration

#### VS Code Setup
Install these extensions:
- Flutter
- Dart
- GitLens
- Material Icon Theme

#### Android Studio Setup
Install these plugins:
- Flutter
- Dart
- Rainbow Brackets
- Key Promoter X

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)

### Community Support
- [Flutter Discord](https://discord.gg/flutter)
- [Flutter Reddit](https://www.reddit.com/r/FlutterDev/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Video Tutorials
- [Flutter YouTube Channel](https://www.youtube.com/c/flutterdev)
- [Riverpod Tutorials](https://www.youtube.com/watch?v=nfWH9HZfNzI)

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] Flutter doctor shows no issues
- [ ] Project builds without errors
- [ ] App runs on target device/emulator
- [ ] Hot reload works properly
- [ ] All features function correctly
- [ ] Tests pass successfully

## 🔄 Updating TodoFlow

To update to the latest version:

```bash
# Pull latest changes
git pull origin main

# Update dependencies
flutter pub get

# Regenerate code if needed
flutter pub run build_runner build --delete-conflicting-outputs

# Clean and rebuild
flutter clean
flutter run
```

---

**Need More Help?**
- Check [Development Guide](DEVELOPMENT_GUIDE.md) for advanced topics
- Review [README.md](README.md) for project overview
- Submit issues on GitHub with detailed information

**Happy Coding! 🚀**
