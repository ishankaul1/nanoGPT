# Use PyTorch CUDA base image
FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel

# Build arg to choose requirements file
ARG REQUIREMENTS_FILE=requirements_cuda.txt

# Set working directory for application code (not in /workspace)
WORKDIR /app/nanogpt

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY ${REQUIREMENTS_FILE} requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install gcloud cli for file syncing
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y \
    && apt-get install google-cloud-cli -y

# Copy service account credentials and set env var (private docker repository; this is okay)
COPY gcs-service-account-key.json /app/
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcs-service-account-key.json

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
ENV GCS_BUCKET="ai-experiments-479020"

# Create workspace directory for persistent data only
# TODO - get rid of this; force output_dir to exist in train.sh instead
# RUN mkdir -p /runpod/outputs

# Default arguments (can be overridden)
CMD ["./train.sh", "--dataset", "shakespeare_char", "--config", "config/train_shakespeare_char.py", "--out_dir", "/workspace/outputs"]