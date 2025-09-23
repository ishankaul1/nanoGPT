#!/usr/bin/env bash
set -euo pipefail
PID="$1"  # pod id
runpodctl stop pod "$PID"
echo