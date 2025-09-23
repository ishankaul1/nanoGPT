#!/usr/bin/env bash
set -euo pipefail

# Script that wraps dataset preparation and training.
# Gives you a single entrypoint to do both. Useful for Dockerfiles/cloud pods.

usage() {
  echo "Usage: $(basename "$0") --dataset <name> --config <path> [extra train.py args...]"
  echo "Example:"
  echo "   ./train.sh --dataset shakespeare_char --config config/train_shakespeare_char.py --compile=False --max_iters=500 --eval_iters=20 --device=mps"
}

DATASET=""
CONFIG=""

# Parse the first two required flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset|-d) DATASET="$2"; shift 2 ;;
    --config|-c) CONFIG="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --) shift; break ;;   # stop parsing, everything after goes to train.py
    *) break ;;           # bail out, rest goes to train.py
  esac
done

# Validate required args
if [[ -z "$DATASET" || -z "$CONFIG" ]]; then
  echo "Error: both --dataset and --config are required."
  usage
  exit 1
fi


# Run prepare if it exists
if [[ -f "data/${DATASET}/prepare.py" ]]; then
  echo "[train.sh] Preparing dataset: $DATASET"
  python "data/${DATASET}/prepare.py"
fi

# Forward everything else to train.py
echo "[train.sh] Starting training with config=$CONFIG dataset=$DATASET"
python train.py "$CONFIG" "$@"
