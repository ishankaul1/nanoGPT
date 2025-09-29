# **NanoGPT SideQuest** ⚔️🪄🏰

Getting hands-on with **[NanoGPT](https://github.com/karpathy/nanoGPT)** to explore and understand:

- 🧠 Transformer architecture itself  
- 🏗️ Infrastructure for training, evaluating, and serving transformers  
- 🔥 PyTorch fundamentals  
- 🧪 The experimentation process end-to-end

---

## 🗺️ **Roadmap**  
> _Subject to change as tinkering evolves!_

### 1. 🚀 **Repeatable GPU Deployment**

Goal: Scripts, Dockerfiles, and infra to make it **easy to train / fine-tune + evaluate mid–large models** on GPUs.

**✅ Checklist**

- [x] Single entrypoint scripts to prep data & train locally on Mac  
- [x] Helper scripts for deploying onto GPU provider (Runpod)  
- [ ] Flexible single-entrypoint Dockerfile deployable to RunPod  
  - _**You are here**_ 🧭  
  - Most of this is set up — currently debugging why local run gets stuck in an infinite loop and never runs forward 🤔  
  - Example cmd:  
    ```bash
    ./build_and_run.sh run --no-gpu --device=cpu --max_iters=100 \
      --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 \
      --mount-output ./test_outputs
    ```
- [ ] Docker image successfully runs Shakespeare Char train on GPU  
- [ ] Checkpointed model, logs, and Weights & Biases (wandb) outputs can be pulled out cleanly  
- [ ] Full retrain on OpenWebText using GPU  
- [ ] Try distributed / faster runs  
- [ ] Fine-tune with Shakespeare or another dataset

---

### 2. 🧠 **Experimentation**

Some fun directions to try:

- ✨ Add **ROPE** (Rotary Position Embeddings)  
- 📈 Add more metrics to logging  
- 🧮 Tinker with model size & hyperparameters  
- 🧠 Incorporate more modern architectural add-ons (from newer papers)  
- 🪄 Experiment with fine-tuning using **QLoRA / LoRA** setups  
- 🧭 Retrain or fine-tune using fancy RL methods

---

### 3. 🧬 **Advanced Stuff**  
> Might move out of this repo eventually.

- 🧠 Add **multimodality**  
- 🧪 Fine-tune or modify **open-source models**

---

✨ **Why this exists**: This is a sandbox for learning — less about shipping production code, more about **deeply understanding how transformers and their ecosystems work**.
