
# Create a super simple test with just a basic command
export NAME="nanogpt-test-2"
export GPU_TYPE="NVIDIA RTX A4000"
export IMAGE="dockerish999/nanogpt-trainer:latest"
export DISK_GB=20
export VOL_GB=10
export START="echo 'Container started!' && sleep 300"

runpodctl create pods --name "$NAME" --gpuType "$GPU_TYPE" \
  --imageName "$IMAGE" --containerDiskSize "$DISK_GB" \
  --volumeSize "$VOL_GB" --args "$START" --secureCloud