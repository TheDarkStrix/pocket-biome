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
./tools/godot.sh --headless --editor --import --quit
./tools/check.sh
staging="builds/PocketBiome-debug.new.apk"
rm -f "$staging"
./tools/godot.sh --headless --export-debug Android "$staging"
test -s "$staging"
"$ANDROID_HOME/build-tools/36.1.0/apksigner" verify "$staging"
mv "$staging" builds/PocketBiome-debug.apk
sha256sum builds/PocketBiome-debug.apk > builds/PocketBiome-debug.apk.sha256
