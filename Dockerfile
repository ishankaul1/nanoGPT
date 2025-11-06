# Use PyTorch CUDA base image
FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel

# Set working directory for application code (not in /workspace)
WORKDIR /app/nanogpt

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the core training files
COPY train.py .
COPY model.py .
COPY configurator.py .
COPY train.sh .

# Copy data and config directories
COPY data/ ./data/
COPY config/ ./config/

# Ensure train.sh executable
RUN chmod +x train.sh

# Set default environment variables (can be overridden at runtime)
ENV DATASET="shakespeare_char"
ENV CONFIG="config/train_shakespeare_char.py"
ENV DEVICE="cuda"
ENV WANDB_MODE="disabled"

# Create workspace directory for persistent data only
RUN mkdir -p /workspace/outputs

# Default arguments (can be overridden)
CMD ["./train.sh", "--dataset", "shakespeare_char", "--config", "config/train_shakespeare_char.py", "--out_dir", "/workspace/outputs"]
