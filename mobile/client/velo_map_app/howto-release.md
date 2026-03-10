# How to Release a New Version to Google Play Store

## Prerequisites (one-time setup, already done)

- Upload keystore at `~/upload-keystore.jks`
- `android/key.properties` with signing credentials (in `.gitignore`)
- `android/app/build.gradle.kts` configured for release signing
- `JAVA_HOME` set in `~/.zshrc` pointing to Android Studio JDK
- Google Play Developer account

---

## Release Steps

### 1. Update Version Number

Edit `pubspec.yaml` and bump the version:

```yaml
version: 1.1.0+2
#        ^^^^^  ^
#        |      |
#        |      versionCode (must increment every upload, Google requires this)
#        versionName (what users see, e.g. 1.0.0 → 1.1.0)
```

**Important:** The `versionCode` (number after `+`) **must increase** with every upload to Google Play. Google will reject the bundle otherwise.

### 2. Run Quality Checks

```bash
# Format code
dart format .

# Run static analysis (must pass for CI)
flutter analyze --fatal-infos

# Run tests
flutter test
```

### 3. Build the AAB Bundle

```bash
flutter build appbundle --release
```

Output will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 4. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select the **VeloMap** app
3. Navigate to **Release** → **Testing** (Internal/Closed/Open) or **Production**
4. Click **Create new release**
5. Upload `build/app/outputs/bundle/release/app-release.aab`
6. Add **release notes** describing what changed
7. Click **Review release** → **Start rollout**

### 5. Commit and Tag

```bash
git add pubspec.yaml
git commit -m "release: v1.1.0"
git tag v1.1.0
git push origin master --tags
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Build release AAB | `flutter build appbundle --release` |
| Build release APK | `flutter build apk --release` |
| Install APK on device | `flutter install --release` |
| Run release on device | `flutter run --release` |
| Check connected devices | `flutter devices` |

## Troubleshooting

### "Signatures do not match" error when installing APK
```bash
adb uninstall app.velofactory.velomap
```
Then install again.

### Java/keytool not found
Make sure `~/.zshrc` has:
```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```
Then restart terminal or run `source ~/.zshrc`.

### Verify keystore
```bash
keytool -list -v -keystore ~/upload-keystore.jks
```
