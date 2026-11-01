# Signing

Signing material is never committed. Step 9 of the implementation plan adds these values to GitHub secrets, used only by the workflow on `main`.

## Android

Release builds use the upload key when `android/key.properties` exists, and the debug key otherwise. The file is ignored by git, and holds:

```properties
keyAlias=upload
keyPassword=<password>
storeFile=<absolute path to the keystore>
storePassword=<password>
```

Back up the keystore and its password somewhere safe.

## iOS

Ad hoc builds need the following, all from an Apple Developer account:

1. Register the App ID `com.opichon.word9`.
2. Register each test iPhone's device ID.
3. Create an Apple Distribution certificate.
4. Create an Ad Hoc provisioning profile for the App ID, certificate and devices. Every newly registered iPhone means regenerating this profile.
5. Set the Team ID in Xcode's Signing settings for the Runner target.

Then build with `flutter build ipa --release --export-method ad-hoc`.

## Diawi

Create an API token in the Diawi account. Step 9 stores it as a GitHub secret.
