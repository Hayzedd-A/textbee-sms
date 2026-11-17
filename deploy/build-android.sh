#!/usr/bin/env bash
# Build the custom TextBee Android APK (prod flavor) pointed at our own backend.
# Run from the repo root, on a machine with the Android SDK (Android Studio's bundled
# SDK is fine — just add its platform-tools/cmdline-tools to PATH, or open the android/
# folder in Android Studio and run the equivalent Gradle task from there instead).
#
# Manual prerequisite: android/app/src/prod/google-services.json must exist, downloaded
# from the Firebase app registered with package name com.vernu.sms (there's a
# google-services.sample.json alongside it showing the shape).
#
# Normal build (uses the real domain baked into android/app/build.gradle):
#   deploy/build-android.sh
#
# Local test build, pointed at a tunnel instead of the real domain — run this first
# in another terminal to get the URL:
#   cloudflared tunnel --url http://localhost:3001
# then:
#   deploy/build-android.sh https://<your-tunnel>.trycloudflare.com/api/v1/
set -euo pipefail

cd "$(dirname "$0")/../android"

if [ ! -f app/src/prod/google-services.json ]; then
  echo "Missing android/app/src/prod/google-services.json — add it before building." >&2
  exit 1
fi

if [ -n "${1:-}" ]; then
  echo "Building against override API_BASE_URL: $1"
  ./gradlew assembleProdRelease -PAPI_BASE_URL_OVERRIDE="$1"
else
  ./gradlew assembleProdRelease
fi

echo "APK at: android/app/build/outputs/apk/prod/release/"
echo "Note: release build signs with the debug keystore by default (see signingConfigs"
echo "in app/build.gradle). Fine for a single internal device; add a real signing"
echo "config before distributing this APK more broadly."
