#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export XDG_DATA_HOME="${XDG_DATA_HOME:-/workspace/runtime/data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/runtime/config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/runtime/cache}"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
exec godot --path . "$@"
