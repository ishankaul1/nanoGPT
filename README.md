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
  - Almost there. LAST piece is figuring out why my checkpoint file didn't make it into my mounted output. 
  - Test cmd:  
    ```bash
    ./build_and_run.sh run --no-gpu --device=cpu --max_iters=100 \
      --n_layer=2 --n_head=4 --n_embd=128 --batch_size=2 --eval_iters=5 \
      --mount-output ./test_outputs
    ```
- [ ] Docker image successfully runs Shakespeare Char train on GPU  
- [ ] Dial in on eval setup
  - [ ] Wandb integration working end-to-end (logs sync from container)  
  - [ ] Training loss + validation loss curves  
  - [ ] Gradient norms (helps catch instability early)  
  - [ ] Learning rate schedule visualization  
  - [ ] Sample generation at checkpoints (qualitative eval — does it look like Shakespeare?)  
  - [ ] Perplexity metrics  
  - [ ] Token/sec throughput (you'll care about this when experimenting)
  - [ ] All checkpoints must make it out into RunPod (if not already done)
- [ ] Full retrain on OpenWebText using GPU  
- [ ] Try distributed / faster runs  
---

### 2. 🧠 **Architecture & Experimentation**

Some fun directions to try:

- ✨ Add modern architectural changes; retrain and see effect on training inference. Some ideas -
  - SwiGLU + RMSNorm
  - RoPE
  - KV cache (inference)
  - GQA (inference)
  - Multimodal (vision+text)
  - MoE
- 🧮 Tinker with model size & hyperparameters  
- 🪄 Experiment with fine-tuning using **QLoRA / LoRA** setups  
- 🧭 Retrain or fine-tune using fancy RL methods

---

### 3. 🧬 **Advanced Stuff**  
> Might move out of this repo eventually.

- 🧪 Fine-tune or modify **open-source models**
- 🧠 More **multimodality** 
- Try Muons?


---

✨ **Why this exists**: This is a sandbox for learning — less about shipping production code, more about **deeply understanding how transformers and their ecosystems work**.
