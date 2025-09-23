#!/usr/bin/env bash
set -euo pipefail
PID="$1"
runpodctl logs pod "$PID" -f