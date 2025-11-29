#!/usr/bin/env bash
# build_and_run.sh - Helper script for building and running the nanoGPT Docker image

set -euo pipefail

# NOTE: Dockerfile now carries service accounts; DO NOT push to public registries anymore!
IMAGE_NAME="${IMAGE_NAME:-nanogpt-trainer-private}"
REGISTRY="${REGISTRY:-dockerish999}"

usage() {
    echo "Usage: $(basename "$0") [build-local|build-cuda|run] [options...]"
    echo ""
    echo "Commands:"
    echo "  build-local              Build for local CPU testing (tag: latest-local)"
    echo "  build-cuda               Build for CUDA and push to registry (tag: latest)"
    echo "  run [options...]         Run the container locally with training"
    echo ""
    echo "Environment variables:"
    echo "  IMAGE_NAME               Image name (default: nanogpt-trainer-private)"
    echo "  TAG                      Override default tag"
    echo "  REGISTRY                 Registry prefix (default: dockerish999)"
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
    echo "  $(basename "$0") build-local"
    echo "  $(basename "$0") build-cuda"
    echo "  TAG=v1.0 $(basename "$0") build-cuda"
    echo "  $(basename "$0") run --dataset shakespeare_char --wandb-key YOUR_KEY"
    echo "  $(basename "$0") run --no-gpu --device=cpu --max_iters=100 --mount-output ./test_outputs"
}

build_local() {
    local tag="${TAG:-latest-local}"
    local full_image="${IMAGE_NAME}:${tag}"
    
    echo "Building local Docker image: ${full_image}"
    echo "Using requirements_local.txt for CPU-only torch"
    docker build \
        --build-arg REQUIREMENTS_FILE=requirements_local.txt \
        -t "${full_image}" \
        .
    echo "Build complete!"
}

build_cuda() {
    local tag="${TAG:-latest}"
    local full_image="${REGISTRY}/${IMAGE_NAME}:${tag}"
    
    echo "Building CUDA Docker image: ${full_image}"
    echo "Using requirements_cuda.txt (torch from base image)"
    docker buildx build \
        --platform linux/amd64 \
        --build-arg REQUIREMENTS_FILE=requirements_cuda.txt \
        -t "${full_image}" \
        --push \
        .
    echo "Build and push complete!"
}

run_container() {
    local tag="${TAG:-latest-local}"
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
        echo "Mounting output directory: $mount_output"
        mkdir -p "$mount_output"
        # Convert to absolute path
        local abs_mount_output="$(cd "$(dirname "$mount_output")" && pwd)/$(basename "$mount_output")"
        echo "Absolute path: ${abs_mount_output}"
        docker_cmd+=("-v" "${abs_mount_output}:/workspace/outputs")
    fi
    
    # Add image and any extra args
    docker_cmd+=("${IMAGE_NAME}:${tag}")
    
    # Add dataset/config args and any extra args
    docker_cmd+=("--dataset" "${dataset}" "--config" "${config}" "--out_dir=/workspace/outputs")
    if [[ ${#extra_args[@]} -gt 0 ]]; then
        docker_cmd+=("${extra_args[@]}")
    fi
    
    echo "Running container with command:"
    echo "${docker_cmd[*]}"
    echo ""
    
    exec "${docker_cmd[@]}"
}

# Main command handling
case "${1:-}" in
    build-local)
        build_local
        ;;
    build-cuda)
        build_cuda
        ;;
    run)
        shift
        run_container "$@"
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