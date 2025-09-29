# NanoGPT Docker Training Setup

This repository contains a Dockerized setup for training nanoGPT models that can be deployed on cloud GPU platforms like RunPod.

## Prerequisites

- Docker installed and running
- Docker Hub account (for pushing images)
- W&B account (optional, for experiment tracking)

## Quick Start

### 1. Build the Docker Image

```bash
./build_and_run.sh build
```

NOTE TO SELF: Docker auth outage rn. Should follow up on their status/incident report and try building again when it's fixed. Pytorch 2.1 worked on build, but training failed bc of a version mismatch. Training directly on my local worked with 2.8, so need to rebuild with the new dockerfile.

This creates a `nanogpt-trainer:latest` image with PyTorch 2.8.0 and all dependencies.

### 2. Test Locally (CPU)

```bash
./build_and_run.sh run --no-gpu --device=cpu --max_iters=100 --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 --mount-output ./test_outputs

```

This runs a short training session on CPU to verify everything works. Outputs will be saved to `./test_outputs/` on your local machine.

### 3. Push to Registry

First, tag the image with your Docker Hub username:

```bash
docker tag nanogpt-trainer:latest yourusername/nanogpt-trainer:latest
```

Then push to Docker Hub:

```bash
docker push yourusername/nanogpt-trainer:latest
```

### 4. Deploy on RunPod

Use your pushed image (`yourusername/nanogpt-trainer:latest`) when creating a RunPod instance.

## Build Script Usage

The `build_and_run.sh` script supports three main commands:

### Build Command
```bash
./build_and_run.sh build
```

### Run Command
```bash
./build_and_run.sh run [options...]
```

**Run Options:**
- `--dataset <name>` - Dataset to use (default: shakespeare_char)
- `--config <path>` - Config file path (default: config/train_shakespeare_char.py)
- `--wandb-key <key>` - W&B API key for logging
- `--gpu <id>` - GPU device ID (default: 0)
- `--no-gpu` - Run without GPU support (for local testing)
- `--mount-output <path>` - Mount local directory for outputs

### Push Command
```bash
./build_and_run.sh push
```

## Training Examples

### Local CPU Testing
```bash
./build_and_run.sh run --no-gpu --device=cpu --max_iters=100 --mount-output ./test_outputs
```

### Local GPU Testing (if you have CUDA)
```bash
./build_and_run.sh run --device=cuda --max_iters=500 --mount-output ./outputs
```

### Production Training (for RunPod)
```bash
./build_and_run.sh run --dataset shakespeare_char --config config/train_shakespeare_char.py --wandb-key YOUR_KEY --max_iters=5000
```
