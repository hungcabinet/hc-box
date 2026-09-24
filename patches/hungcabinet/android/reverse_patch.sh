#!/usr/bin/env bash
set -euo pipefail

echo "== Android overlay reverse (assets only) =="

ANDROID_DIR="clients/android"
PATCH_ROOT="${PATCH_ROOT:-patches/hungcabinet/android}"
OVERLAY_DIR="${OVERLAY_DIR:-$PATCH_ROOT/overlay}"

echo "Source: $ANDROID_DIR"
echo "Overlay: $OVERLAY_DIR"

if [ ! -d "$OVERLAY_DIR" ]; then
  echo "ERROR: Overlay directory not found: $OVERLAY_DIR"
  exit 1
fi

if [ ! -d "$ANDROID_DIR" ]; then
  echo "ERROR: Android directory not found: $ANDROID_DIR"
  exit 1
fi

copied=0
missing=0

while IFS= read -r -d '' overlay_file; do
  rel="${overlay_file#"$OVERLAY_DIR"/}"
  src="$ANDROID_DIR/$rel"

  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$overlay_file")"
    cp -a "$src" "$overlay_file"
    echo "  <- $rel"
    copied=$((copied + 1))
  else
    echo "  WARNING: not found in repo: $rel"
    missing=$((missing + 1))
  fi
done < <(find "$OVERLAY_DIR" -type f -print0)

echo "Reverse overlay complete: $copied file(s) updated"
if [ "$missing" -gt 0 ]; then
  echo "WARNING: $missing overlay file(s) missing from $ANDROID_DIR"
fi

echo
echo "Note: surgical code changes live in $PATCH_ROOT/patches/*.patch"
echo "Regenerate them with: python $PATCH_ROOT/generate_patches.py"
echo "== Done =="
