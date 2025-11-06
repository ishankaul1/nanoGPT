#!/usr/bin/env bash
set -euo pipefail

# Configuration
export NAME="nanogpt-smoke-test"
export GPU_TYPE="NVIDIA GeForce RTX 3070"
export IMAGE="dockerish999/nanogpt-trainer:latest"
export DISK_GB=20
export VOL_GB=10
export START="./build_and_run.sh run --device=gpu --max_iters=100 --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 --eval_iters=5 --always_save_checkpoint=True --eval_interval=100 --mount-output ./workspace"

# Create the pod
cmd=(
  runpodctl create pods
  --name "$NAME"
  --gpuType "$GPU_TYPE"
  --imageName "$IMAGE"
  --containerDiskSize "$DISK_GB"
  --volumeSize "$VOL_GB"
  --secureCloud
)

# Append the start command
if [[ -n "$START" ]]; then
  cmd+=( --args "$START" )
fi

echo "Creating RunPod instance with:"
echo "  Name: $NAME"
echo "  GPU: $GPU_TYPE"
echo "  Image: $IMAGE"
echo "  Container Disk: ${DISK_GB}GB"
echo "  Volume: ${VOL_GB}GB"
echo "  Start Command: $START"
echo ""

# Execute the command
"${cmd[@]}"

echo ""
echo "Pod created! Use 'runpodctl get pod $NAME' to check status"
echo "Checkpoints will be saved to /workspace volume"