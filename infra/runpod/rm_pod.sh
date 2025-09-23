#!/usr/bin/env bash
set -euo pipefail
PID="$1"
runpodctl remove pod "$PID"
