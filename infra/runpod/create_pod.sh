#!/usr/bin/env bash
set -euo pipefail

NAME=${NAME}
GPU_TYPE=${GPU_TYPE}
IMAGE=${IMAGE}
DISK_GB=${DISK_GB}
VOL_GB=${VOL_GB}
START=${START:-}

cmd=(
  runpodctl create pods
  --name "$NAME"
  --gpuType "$GPU_TYPE"
  --imageName "$IMAGE"
  --containerDiskSize "$DISK_GB"
  --volumeSize "$VOL_GB"
)

# only append --args if START is set & non-empty
if [[ -n "$START" ]]; then
  cmd+=( --args "$START" )
fi

"${cmd[@]}"