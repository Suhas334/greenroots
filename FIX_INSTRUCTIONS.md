# GreenRoots Android storage fix

## Root cause
The installed release APK throws a Java `NoSuchMethodError` for `SharedPreferencesApiRegistrar.getAll(...)` when using the Flutter `shared_preferences` plugin. This is a native plugin binary mismatch, not a Dart JSON problem.

## Change
The app now uses a minimal Android MethodChannel in `MainActivity.kt` to read/write the *existing* Android SharedPreferences file `FlutterSharedPreferences` and preference key `flutter.trees_v1`. The Dart `TreeStorage` continues serializing the same JSON list of `TreeRecord`s. The problematic plugin dependency is removed.

Do not uninstall the old app or clear app data. Install the new APK over it, with the same application ID and signing certificate. This repository currently uses the debug signing configuration for release builds; changing signing keys would prevent an in-place upgrade.

## In Codespaces

```sh
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test --reporter expanded
flutter build apk --release
```

If tests pass, commit and push, then download the new APK from GitHub Actions. Confirm old Neem records appear, add a new tree, force-close and reopen, and confirm the new tree remains.

Note: the native Android bridge has not been compiled or tested on an actual phone in the assistant environment.
