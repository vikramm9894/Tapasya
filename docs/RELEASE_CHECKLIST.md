# Tapasya — Google Play Store Release Checklist (Phase 6)

## 1. App Identity & Signing Key Setup
- [ ] **Package Name:** `com.vikram.tapasya` (or `com.tapasya.app`)
- [ ] **Keystore Generation:** Generate production upload keystore:
  ```powershell
  keytool -genkey -v -keystore C:\Users\vikra\tapasya_upload_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tapasya
  ```
- [ ] **Backup Keystore:** Store `tapasya_upload_key.jks` and credentials safely in 1Password / Google Drive.

## 2. Release Build Command
Build the optimized, production-ready Android App Bundle (`.aab`):
```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 3. Google Play Console Listing Assets
- [ ] **App Name:** Tapasya (तपस्या) — 90-Day Discipline & Focus
- [ ] **Short Description:** Roz thoda. 90 din tak. Compassionate smart streak, non-negotiables & focus timer.
- [ ] **Full Description:** Comprehensive Hindi + English copy focusing on the 90-day disciplined transformation ("Winter Arc"), bare minimum bad-day mode, and zero cloud tracking.
- [ ] **App Icon:** 512x512 PNG (32-bit with alpha).
- [ ] **Feature Graphic:** 1024x500 JPEG/PNG.
- [ ] **Screenshots:** 4 to 8 high-resolution 9:16 screenshots covering Today, Progress Heatmap, Focus Timer, and Season Recap.

## 4. Google Play Data Safety Declarations
- **Data Collection:** Does the app collect user data? $\rightarrow$ **No.**
- **Storage:** All data (habits, reflections, focus hours) is stored **strictly on the user's device** using local SQLite.
- **Third-Party Sharing:** **No data shared with third parties.**
- **Biometric Data:** Processed locally by Android biometric prompt; never accessed by the app code.

## 5. Google Closed Testing Requirements
For personal developer accounts created after November 2023:
- [ ] Create **Closed Testing Track**.
- [ ] Recruit at least **20 testers** opted-in for at least **14 consecutive days**.
- [ ] Gather feedback and push maintenance updates if needed.
- [ ] Apply for Production Access directly in Play Console.
