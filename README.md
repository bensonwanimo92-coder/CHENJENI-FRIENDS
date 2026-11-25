# WordQuest Android wrapper
This project packages the WordQuest HTML game as an Android WebView app. The HTML game is bundled locally and does not require network access to play.

## Build
Run `gradle assembleDebug` with Android SDK (platform 35) and Java 17 installed, or push this project to GitHub and run Actions workflow `Build WordQuest APK` manually. The workflow uploads a debug APK artifact.

This is a debug APK configuration; signing for Play Store release is not configured.
