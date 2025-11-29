#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") --dataset <name> --config <path> [extra train.py args...]"
  echo "Example:"
  echo "   ./train.sh --dataset shakespeare_char --config config/train_shakespeare_char.py --compile=False --max_iters=500 --eval_iters=20 --device=mps"

  echo "NOTE: Top-level required vars are --var <value> format. All extra args are forwarded to train.py, and passed in as --key=value."
}

DATASET=""
CONFIG=""

# Folder for experiment in the cloud
EXPERIMENT_FOLDER=""

# Local folder to put outputs
OUTPUT_DIR=""

# Extra args are non-first order configs; we'll forward them to train.py for flexibility
EXTRA_ARGS=()

# Parse all arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset|-d) DATASET="$2"; shift 2 ;;
    --config|-c) CONFIG="$2"; shift 2 ;;
    --experiment-folder) EXPERIMENT_FOLDER="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) EXTRA_ARGS+=("$1"); shift ;;  # collect everything else
  esac
done

# Validate required args
if [[ -z "$DATASET" || -z "$CONFIG" ]]; then
  echo "Error: both --dataset and --config are required."
  usage
  exit 1
fi

GCS_BUCKET="${GCS_BUCKET:-}"
if [[ -z "$GCS_BUCKET" ]]; then
  echo "Error: GCS_BUCKET environment variable must be set"
  echo "Example: export GCS_BUCKET=my-nanogpt-experiments"
  exit 1
fi

# Fill in experiment folder and output dir if not provided
if [[ -z "$EXPERIMENT_FOLDER" ]]; then
  CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")
  # Want something generally descriptive and unique
  EXPERIMENT_FOLDER="experiments/llm_train/${DATASET}/${CURRENT_TIME}"
  echo "[train.sh] No experiment folder provided. Using default: $EXPERIMENT_FOLDER"
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  # Output dir is local; just use outputs/
  OUTPUT_DIR="outputs/"
  echo "[train.sh] No output directory provided. Using default: $OUTPUT_DIR"
fi

# Check if dataset prepare.py exists, else crash
if [[ -f "data/${DATASET}/prepare.py" ]]; then
  echo "[train.sh] Preparing dataset: $DATASET"
  python "data/${DATASET}/prepare.py"
else
  echo "[train.sh] ERROR: Dataset prepare.py not found for '$DATASET' at data/${DATASET}/prepare.py"
  exit 1
fi


# Background sync loop - runs every 5 minutes
echo "[train.sh] Starting background sync to gs://${GCS_BUCKET}/${EXPERIMENT_FOLDER}"

(
  while true; do
    gcloud storage rsync "$OUTPUT_DIR" "gs://${GCS_BUCKET}/${EXPERIMENT_FOLDER}/" --recursive
    sleep 300
  done
) &
SYNC_PID=$!

# Optional: trap to kill sync on exit (not strictly necessary but clean)
trap "kill $SYNC_PID 2>/dev/null; wait $SYNC_PID 2>/dev/null" EXIT

# Forward everything else to train.py
echo "[train.sh] About to run python train.py with args:"
echo "[train.sh] python train.py $CONFIG ${EXTRA_ARGS[@]}"

python train.py "$CONFIG" "${EXTRA_ARGS[@]}"

# Final sync after training completes
echo "[train.sh] Training complete. Running final sync..."
gcloud storage rsync "$OUTPUT_DIR" "gs://${GCS_BUCKET}/${EXPERIMENT_FOLDER}/" --recursive
echo "[train.sh] Final sync complete. Checkpoints saved to gs://${GCS_BUCKET}/${EXPERIMENT_FOLDER}"