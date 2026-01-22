# VeloMap App

A Flutter-based cycling/bike route mapping and navigation application with Mapbox integration.

## Prerequisites

- Flutter SDK 3.10.7 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)
- A valid Mapbox API key

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure environment variables
Create a `.env` file in the project root:
```bash
cp .env.example .env
```

Add your Mapbox API key:
```
MAPBOX_KEY=your_mapbox_api_key_here
```

## Launch & Debug

### List Available Devices
```bash
# Show all connected devices and emulators
flutter devices

# List available emulators (not running)
flutter emulators
```

### Start Emulators
```bash
# iOS Simulator
flutter emulators --launch apple_ios_simulator

# Android Emulator
flutter emulators --launch Pixel_9_Pro
# or
flutter emulators --launch Pixel_7_Pro_API_35
```

### Run the App

#### iOS Only
```bash
flutter run -d iPhone
```

#### Android Only
```bash
flutter run -d emulator-5554
# or use auto-detection
flutter run -d emulator
```

#### Both Android & iOS (in separate terminals)
**Terminal 1:**
```bash
flutter run -d iPhone
```
**Terminal 2:**
```bash
flutter run -d emulator-5554
```

### Debug Mode Commands

While the app is running in debug mode, you can use these keyboard shortcuts in the terminal:

| Key | Action |
|-----|--------|
| `r` | Hot reload (apply code changes instantly) |
| `R` | Hot restart (restart the app, preserves state) |
| `h` | Show all available commands |
| `d` | Detach (leave app running) |
| `c` | Clear the screen |
| `q` | Quit (stop the app) |

### VS Code Debugging

1. Open the project in VS Code
2. Go to **Run and Debug** (Cmd+Shift+D)
3. Select a device from the device selector in the status bar
4. Press **F5** or click **Start Debugging**

### Flutter DevTools

Check size
```bash
flutter build apk --analyze-size --target-platform android-arm64
```

Launch Flutter DevTools for advanced debugging:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Or open DevTools from a running app:
```bash
# While app is running, press 'v' to open DevTools in browser
```

## Build

### Debug Build
```bash
# iOS
flutter build ios --debug

# Android
flutter build apk --debug
```

### Release Build
```bash
# iOS
flutter build ios --release

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

### Format 
```bash
dart format .
```

### Analuze issues
```bash
flutter analyze --fatal-infos
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app/
│   ├── app.dart           # Root MaterialApp widget
│   └── router.dart        # GoRouter navigation setup
├── errors/
│   └── bloc_observable.dart  # BLoC event/error logging
└── features/
    ├── navigation/        # Turn-by-turn navigation (coming soon)
    └── routes/            # Main map screen with route list
```

## Troubleshooting

### Android emulator won't start
If you get "The Android emulator exited with code 1", the emulator may already be running:
```bash
# Check running devices
flutter devices

# Kill existing emulator if needed
/Users/$USER/Library/Android/sdk/platform-tools/adb emu kill

# Then relaunch
flutter emulators --launch Pixel_9_Pro
```

### iOS build fails
```bash
# Update CocoaPods
cd ios && pod install --repo-update && cd ..

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d iPhone
```

### Mapbox not loading
Ensure your `MAPBOX_KEY` is set correctly in the `.env` file and the key has the necessary permissions for Maps SDK.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Mapbox Flutter SDK](https://docs.mapbox.com/flutter/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter BLoC](https://bloclibrary.dev/)
