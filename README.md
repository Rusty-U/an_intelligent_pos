# Intelligent POS (Full)

Blue/white professional POS app inspired by Zobaze:
- Splash screen (logo placeholder)
- Dashboard: **New Sale** button + empty area reserved for AI embed
- Inventory, Staff, Sales, Reports, Settings
- Firestore wiring (collections: `inventory`, `sales`, `staff`)

## Run
```bash
flutter pub get
# Add Firebase:
# 1) dart pub global activate flutterfire_cli
# 2) flutterfire configure   (generates lib/firebase_options.dart OR use default app config)
# 3) Add google-services.json (android/app) and GoogleService-Info.plist (iOS)
flutter run
```
Replace `assets/icon.png` and `assets/logo.png` later.
