#!/usr/bin/env bash
# build_and_run.sh - Helper script for building and running the nanoGPT Docker image

set -euo pipefail

IMAGE_NAME="nanogpt-trainer"
TAG="latest"

usage() {
    echo "Usage: $(basename "$0") [build|run|push] [options...]"
    echo ""
    echo "Commands:"
    echo "  build                    Build the Docker image"
    echo "  run [options...]         Run the container with training"
    echo "  push                     Push to registry (requires docker login)"
    echo ""
    echo "Run options:"
    echo "  --dataset <name>         Dataset to use (default: shakespeare_char)"
    echo "  --config <path>          Config file path (default: config/train_shakespeare_char.py)"
    echo "  --wandb-key <key>        W&B API key for logging"
    echo "  --gpu <id>               GPU device ID (default: 0)"
    echo "  --no-gpu                 Run without GPU support (for local testing)"
    echo "  --mount-output <path>    Mount local directory for outputs"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") build"
    echo "  $(basename "$0") run --dataset shakespeare_char --wandb-key YOUR_KEY"
    echo "  $(basename "$0") run --no-gpu --device=cpu --max_iters=100 --mount-output ./test_outputs"
    echo "  $(basename "$0") run --dataset openwebtext --config config/train_gpt2.py --mount-output ./outputs"
}

build_image() {
    echo "Building Docker image: ${IMAGE_NAME}:${TAG}"
    docker build -t "${IMAGE_NAME}:${TAG}" .
    echo "Build complete!"
}

run_container() {
    local dataset="shakespeare_char"
    local config="config/train_shakespeare_char.py" 
    local wandb_key=""
    local gpu_id="0"
    local no_gpu=false
    local mount_output=""
    local extra_args=()
    
    # Parse run arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dataset) dataset="$2"; shift 2 ;;
            --config) config="$2"; shift 2 ;;
            --wandb-key) wandb_key="$2"; shift 2 ;;
            --gpu) gpu_id="$2"; shift 2 ;;
            --no-gpu) no_gpu=true; shift ;;
            --mount-output) mount_output="$2"; shift 2 ;;
            *) extra_args+=("$1"); shift ;;
        esac
    done
    
    # Build docker run command
    local docker_cmd=(
        "docker" "run" 
        "--rm"
    )
    
    # Add GPU support unless --no-gpu is specified
    if [[ "$no_gpu" != true ]]; then
        docker_cmd+=("--gpus" "device=${gpu_id}")
    fi
    
    # Add W&B key if provided
    if [[ -n "$wandb_key" ]]; then
        docker_cmd+=("-e" "WANDB_API_KEY=${wandb_key}" "-e" "WANDB_MODE=online")
    fi
    
    # Add output mount if provided
    if [[ -n "$mount_output" ]]; then
        mkdir -p "$mount_output"
        docker_cmd+=("-v" "${mount_output}:/workspace/outputs")
    fi
    
    # Add image and any extra args
    docker_cmd+=("${IMAGE_NAME}:${TAG}")
    
    # Add dataset/config args and any extra args
    docker_cmd+=("--dataset" "${dataset}" "--config" "${config}" "--out_dir=/workspace/outputs")
    docker_cmd+=("${extra_args[@]}")
    
    echo "Running container with command:"
    echo "${docker_cmd[*]}"
    echo ""
    
    exec "${docker_cmd[@]}"
}

push_image() {
    echo "Pushing ${IMAGE_NAME}:${TAG} to registry..."
    docker push "${IMAGE_NAME}:${TAG}"
}

# Main command handling
case "${1:-}" in
    build)
        build_image
        ;;
    run)
        shift
        run_container "$@"
        ;;
    push)
        push_image
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown command '${1:-}'"
        echo ""
        usage
        exit 1
        ;;
esac