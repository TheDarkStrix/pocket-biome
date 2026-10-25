#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME=/workspace/runtime/jdk/jdk-17.0.16+8
export ANDROID_HOME=/workspace/runtime/android-sdk
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME=/workspace/runtime/android-user
export GRADLE_USER_HOME=/workspace/runtime/gradle
mkdir -p builds "$GRADLE_USER_HOME"
python tools/prepare_native.py
import_log=$(mktemp)
trap 'rm -f "$import_log"' EXIT
./tools/godot.sh --headless --editor --import --quit 2>&1 | tee "$import_log"
if rg -q 'SCRIPT ERROR:|^ERROR:' "$import_log"; then
  echo "Import failed; Android export was not attempted." >&2
  exit 1
fi
rm -f "$import_log"
trap - EXIT
python3 tools/write_build_stamp.py
./tools/check.sh
staging="builds/PocketBiome-debug.new.apk"
rm -f "$staging"
export_log=$(mktemp)
trap 'rm -f "$export_log"' EXIT
./tools/godot.sh --headless --export-debug Android "$staging" 2>&1 | tee "$export_log"
if rg -q 'SCRIPT ERROR:|^ERROR:' "$export_log"; then
  echo "Export reported an error; previous APK retained." >&2
  exit 1
fi
rm -f "$export_log"
trap - EXIT
test -s "$staging"
"$ANDROID_HOME/build-tools/36.1.0/apksigner" verify "$staging"
python3 tools/audit_android.py --apk "$staging"
mv "$staging" builds/PocketBiome-debug.apk
sha256sum builds/PocketBiome-debug.apk > builds/PocketBiome-debug.apk.sha256
