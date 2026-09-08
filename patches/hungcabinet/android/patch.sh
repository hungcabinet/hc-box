#!/usr/bin/env bash
set -euo pipefail

echo "== Android overlay patch =="

APP_ID="${APP_ID:-com.hungcabinet.box}"
APP_NAME="${APP_NAME:-hc-box}"
SOURCE_URL="${SOURCE_URL:-https://github.com/hungcabinet/hc-box}"

ANDROID_DIR="clients/android"
OVERLAY_DIR="${OVERLAY_DIR:-patches/hungcabinet/android/overlay}"

echo "APP_ID=$APP_ID"
echo "APP_NAME=$APP_NAME"
echo "SOURCE_URL=$SOURCE_URL"
echo "Overlay source: $OVERLAY_DIR"
echo "Target: $ANDROID_DIR"

if [ ! -d "$OVERLAY_DIR" ]; then
  echo "ERROR: Overlay directory not found: $OVERLAY_DIR"
  exit 1
fi

if [ ! -d "$ANDROID_DIR" ]; then
  echo "ERROR: Android directory not found: $ANDROID_DIR"
  exit 1
fi

echo "Copying branding assets..."
cp -a "$OVERLAY_DIR/." "$ANDROID_DIR/"

BUILD_KTS="$ANDROID_DIR/app/build.gradle.kts"
if [ -f "$BUILD_KTS" ]; then
  echo "Setting applicationId..."
  sed -i -E \
    "s/applicationId[[:space:]]*=[[:space:]]*\"[^\"]+\"/applicationId = \"$APP_ID\"/g" \
    "$BUILD_KTS"
fi

SETTINGS_KT="$ANDROID_DIR/app/src/main/java/io/nekohasekai/sfa/compose/screen/settings/SettingsScreen.kt"
if [ -f "$SETTINGS_KT" ]; then
  echo "Pointing source code link to $SOURCE_URL..."
  sed -i -E \
    "s|https://github.com/SagerNet/sing-box-for-android|${SOURCE_URL}|g" \
    "$SETTINGS_KT"
fi

GITHUB_CHECKER="$ANDROID_DIR/app/src/github/java/io/nekohasekai/sfa/vendor/GitHubUpdateChecker.kt"
if [ -f "$GITHUB_CHECKER" ]; then
  echo "Pointing GitHub updates to hungcabinet/hc-box..."
  sed -i -E \
    's|https://api.github.com/repos/SagerNet/sing-box/releases|https://api.github.com/repos/hungcabinet/hc-box/releases|g' \
    "$GITHUB_CHECKER"
fi

APP_SETTINGS_KT="$ANDROID_DIR/app/src/main/java/io/nekohasekai/sfa/compose/screen/settings/AppSettingsScreen.kt"
if [ -f "$APP_SETTINGS_KT" ]; then
  echo "Keeping GitHub as the only update source in settings UI..."
  sed -i '/"fdroid" to stringResource(R.string.update_source_fdroid),/d' "$APP_SETTINGS_KT"
fi

while IFS= read -r -d '' vendor_kt; do
  if grep -q 'UpdateSource.FDROID' "$vendor_kt"; then
    echo "Dropping F-Droid update source in ${vendor_kt#"$ANDROID_DIR"/}..."
    sed -i -E \
      's/listOf\(UpdateSource\.GITHUB, UpdateSource\.FDROID\)/listOf(UpdateSource.GITHUB)/g' \
      "$vendor_kt"
  fi
done < <(find "$ANDROID_DIR/app/src" -path '*/vendor/Vendor.kt' -print0)

echo "Rebranding strings (stand-alone sing-box, URLs kept)..."
while IFS= read -r -d '' strings_file; do
  sed -i -E "s/sing-box([^.]|$)/${APP_NAME}\1/g" "$strings_file"
done < <(find "$ANDROID_DIR/app/src/main/res" -name 'strings.xml' -print0)

echo "== Done =="
