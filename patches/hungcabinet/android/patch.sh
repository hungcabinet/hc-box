#!/usr/bin/env bash
set -euo pipefail

echo "== Android hungcabinet patch =="

# ======================
# Settings
# ======================
APP_ID="${APP_ID:-com.hungcabinet.box}"
APP_NAME="${APP_NAME:-hc-box}"

ANDROID_DIR="clients/android"
PATCH_ROOT="${PATCH_ROOT:-patches/hungcabinet/android}"
OVERLAY_DIR="${OVERLAY_DIR:-$PATCH_ROOT/overlay}"
PATCHES_DIR="${PATCHES_DIR:-$PATCH_ROOT/patches}"

echo "APP_ID=$APP_ID"
echo "APP_NAME=$APP_NAME"
echo "Target: $ANDROID_DIR"
echo "Patches: $PATCHES_DIR"
echo "Overlay: $OVERLAY_DIR"

if [ ! -d "$ANDROID_DIR" ]; then
  echo "ERROR: Android directory not found: $ANDROID_DIR"
  exit 1
fi

# ======================
# 1. Surgical unified diffs (fail loudly on conflict)
# ======================
if [ -d "$PATCHES_DIR" ] && compgen -G "$PATCHES_DIR/*.patch" > /dev/null; then
  echo "Applying unified patches..."
  for patch_file in "$PATCHES_DIR"/*.patch; do
    echo "  -> $(basename "$patch_file")"
    # --forward: skip if already applied; non-zero still means a real conflict
    if ! patch -d "$ANDROID_DIR" -p1 --forward --batch --reject-file=- --no-backup-if-mismatch < "$patch_file"; then
      if patch -d "$ANDROID_DIR" -p1 -R --dry-run --force < "$patch_file" >/dev/null 2>&1; then
        echo "     (already applied, skipped)"
      else
        echo "ERROR: failed to apply $(basename "$patch_file")"
        echo "Rebase/regenerate with: python $PATCH_ROOT/generate_patches.py"
        exit 1
      fi
    fi
  done
  echo "Patches applied."
else
  echo "WARNING: no *.patch files in $PATCHES_DIR"
fi

# ======================
# 2. Asset overlay (icons, keystore, vector drawables)
# ======================
if [ -d "$OVERLAY_DIR" ]; then
  echo "Applying asset overlay..."
  cp -a "$OVERLAY_DIR/." "$ANDROID_DIR/"
  echo "Overlay applied."
else
  echo "WARNING: overlay directory not found: $OVERLAY_DIR"
fi

# ======================
# 3. applicationId (env override, idempotent)
# ======================
BUILD_KTS="$ANDROID_DIR/app/build.gradle.kts"
if [ -f "$BUILD_KTS" ]; then
  echo "Ensuring applicationId=$APP_ID"
  sed -i -E \
    "s/applicationId[[:space:]]*=[[:space:]]*\"[^\"]+\"/applicationId = \"$APP_ID\"/g" \
    "$BUILD_KTS"
fi

# ======================
# 4. String branding: sing-box -> APP_NAME (safer than full strings.xml overlays)
# ======================
echo "Branding strings.xml as $APP_NAME..."
find "$ANDROID_DIR/app/src/main/res" -type f -name 'strings.xml' -print0 |
  while IFS= read -r -d '' strings_file; do
    # app_name first, then remaining user-facing sing-box mentions
    sed -i -E \
      -e "s/(<string name=\"app_name\"[^>]*>)sing-box(<\\/string>)/\\1${APP_NAME}\\2/g" \
      -e "s/sing-box/${APP_NAME}/g" \
      "$strings_file"
  done

echo "== Done =="
