# NanoGPT Docker Training Setup

This repository contains a Dockerized setup for training nanoGPT models that can be deployed on cloud GPU platforms like RunPod.

## Prerequisites

- Docker installed and running
- Docker Hub account (for pushing images)
- W&B account (optional, for experiment tracking)

## Quick Start

### 1. Build the Docker Image

#### For Local CPU Testing
```bash
./build_and_run.sh build-local
```

This creates a `nanogpt-trainer-private:latest-local` image with CPU-only PyTorch for local testing.

#### For GPU/RunPod Deployment
```bash
./build_and_run.sh build-cuda
```

This builds a `dockerish999/nanogpt-trainer-private:latest` image with CUDA support for linux/amd64 and automatically pushes it to Docker Hub. The image uses the CUDA-enabled PyTorch from the base image.

**Custom tags/registry:**
```bash
TAG=v1.0 REGISTRY=yourusername ./build_and_run.sh build-cuda
```

### 2. Test Locally (CPU)

Run with a VERY small model, low eval_iters and max_iters.
CPU is painstakingly slow.

```bash
./build_and_run.sh run --no-gpu --device=cpu --max_iters=100 \
      --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 --eval_iters=5 \
      --always_save_checkpoint=True \
      --eval_interval=100 \
      --mount-output ./test_outputs
```

This runs a short training session on CPU to verify everything works. Outputs will be saved to `./test_outputs/` on your local machine.

#### Notes
- The script automatically uses the `latest-local` tag for local runs
- Checkpoints save at `eval_interval`, so make sure `max_iters` is divisible by `eval_interval` or set `eval_interval` appropriately
- Use `--always_save_checkpoint=True` for testing to force checkpoint saves
- Output directory is automatically mounted to `/workspace/outputs` in the container

### 3. Deploy to RunPod

After building with `build-cuda`, your image is automatically pushed and ready to use on RunPod. See the RunPod deployment section for details.
