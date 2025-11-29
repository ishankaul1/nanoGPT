#!/usr/bin/env bash
set -euo pipefail

# Configuration
export NAME="nanogpt-smoke-test"
export GPU_TYPE="NVIDIA RTX A4000"
export TEMPLATE_ID="spe4baz8o9"
export IMAGE="dockerish999/nanogpt-trainer-private:latest"
export START="./train.sh --dataset shakespeare_char --config config/train_shakespeare_char.py --out_dir=/runpod/outputs --device=cuda --max_iters=100 --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 --eval_iters=5 --always_save_checkpoint=True --eval_interval=100"
export NETWORK_VOLUME_ID="yzelp7yuep10"
export NETWORK_VOLUME_LOCATION="US-IL-1"

# Create the pod
cmd=(
  runpodctl create pods
  --name "$NAME"
  --gpuType "$GPU_TYPE"
  --templateId "$TEMPLATE_ID"
  --imageName "$IMAGE"
  --dataCenterId
  --secureCloud
)

# Append the start command
if [[ -n "$START" ]]; then
  cmd+=( --args "$START" )
fi

echo "Creating RunPod instance with:"
echo "  Name: $NAME"
echo "  GPU: $GPU_TYPE"
echo "  Template ID: $TEMPLATE_ID"
echo "  Image: $IMAGE"
echo "  Start Command: $START"
echo ""

# Execute the command
"${cmd[@]}"

echo ""
echo "Pod created! Use 'runpodctl get pod $NAME' to check status"
echo "Checkpoints will be saved to /workspace volume"