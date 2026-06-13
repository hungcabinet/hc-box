#!/usr/bin/env bash
set -euo pipefail

echo "== Android overlay reverse patch =="

# ======================
# Настройки
# ======================
ANDROID_DIR="clients/android"
OVERLAY_DIR="${OVERLAY_DIR:-patches/hungcabinet/android/overlay}"

echo "Overlay target: $OVERLAY_DIR"
echo "Source: $ANDROID_DIR"

# ======================
# 1. Проверки
# ======================

if [ ! -d "$OVERLAY_DIR" ]; then
  echo "❌ ERROR: Overlay directory not found!"
  echo "   Expected path: $OVERLAY_DIR"
  exit 1
fi

if [ ! -d "$ANDROID_DIR" ]; then
  echo "❌ ERROR: Android directory not found!"
  echo "   Expected path: $ANDROID_DIR"
  exit 1
fi

echo "Syncing overlay from repository state..."

# ======================
# 2. Копируем обратно только файлы, уже присутствующие в overlay
# ======================

copied=0
missing=0

while IFS= read -r -d '' overlay_file; do
  rel="${overlay_file#"$OVERLAY_DIR"/}"
  src="$ANDROID_DIR/$rel"

  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$overlay_file")"
    cp -a "$src" "$overlay_file"
    echo "  ← $rel"
    copied=$((copied + 1))
  else
    echo "  ⚠️  not found in repo: $rel"
    missing=$((missing + 1))
  fi
done < <(find "$OVERLAY_DIR" -type f -print0)

echo "✅ Reverse patch complete: $copied file(s) updated"
if [ "$missing" -gt 0 ]; then
  echo "⚠️  $missing file(s) from overlay were not found in $ANDROID_DIR"
fi

echo "== Done =="
