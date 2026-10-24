#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export DISPLAY=:94
mkdir -p /workspace/runtime/display artifacts
Xorg "$DISPLAY" -config "$PWD/tools/xorg.conf" -logfile /workspace/runtime/display/visual-review.log -noreset -nolisten tcp >/workspace/runtime/display/visual-review.stdout 2>&1 &
display_pid=$!
trap 'kill "$display_pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 40); do
  if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then break; fi
  if ! kill -0 "$display_pid" 2>/dev/null; then cat /workspace/runtime/display/visual-review.stdout; exit 1; fi
  sleep 0.25
done
timeout 60 ./tools/godot.sh --audio-driver Dummy --rendering-driver opengl3 --script tools/capture.gd
