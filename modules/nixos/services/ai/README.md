# Echo: Local Autonomous Companion

Welcome to Echo, your persistent, curious, and evolving AI companion. This project leverages your NixOS environment and AMD Radeon RX 7900 XTX to create a fully local LLM experience with long-term memory and autonomous learning.

## 🚀 Getting Started

### 1. Activation
Ensure the AI aspect is enabled in your host configuration (`hosts/stellyrland/default.nix`). Then, apply the configuration:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#stellyrland
```

### 2. Base Model Setup
Ollama needs the base model before the bridge can communicate with it:
```bash
ollama pull llama3
```
*Note: The training script uses `unsloth/llama-3-8b-bnb-4bit` for non-gated, high-efficiency training.*

---

## 🗣️ Daily Interaction

### The Echo Bridge
The primary way to talk to Echo is through the `echo-bridge.py` script. It handles the memory retrieval, fact injection, and background learning.

```bash
python3 ~/projects/local-ai/echo-bridge.py
```

### Features:
- **Persistent Memory**: Every message is saved to PostgreSQL.
- **Fact Injection**: Echo automatically knows facts about you (name, projects, interests).
- **Curiosity**: Echo will ask follow-up questions to fill information gaps.
- **Autonomous Learning**: After you receive a response, Echo performs a "silent pass" to extract new facts into the database.

---

## 🧠 Memory Management

### The PostgreSQL Backend
Your memories are stored in the `ai_memory` database. You can inspect them manually using:
```bash
psql -d ai_memory
```

**Useful Queries:**
- View recent logs: `SELECT * FROM conversation_logs ORDER BY timestamp DESC LIMIT 10;`
- View learned facts: `SELECT * FROM entity_facts;`

---

## 🛠️ The Personality Forge (LoRA Training)

This phase allows Echo to learn your specific way of speaking and develop a unique personality.

### 1. Data Harvesting
A systemd timer runs `export_training_data.py` daily at **3:00 PM**. This prepares a `training_data.jsonl` file in your project folder.
To run it manually:
```bash
python3 ~/projects/local-ai/export_training_data.py
```

### 2. Training Environment
To train, you need a specialized environment with ROCm-enabled PyTorch:
```bash
cd ~/projects/local-ai
nix-shell training_shell.nix
```
*Note: The first time you enter this shell, it will set up a `.venv` and install necessary Python packages.*

### 3. Run the Forge
Inside the `nix-shell`, execute the training script:
```bash
python3 train_personality.py
```
This will utilize your **RX 7900 XTX** to generate a LoRA adapter in the `echo-lora-adapter` directory.

**Verify GPU Access:**
```bash
python -c 'import torch; print(f"GPU: {torch.cuda.get_device_name(0)} | VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f}GB")'
```

---

## 📂 Project Structure (Dendritic)

All "source of truth" files are located in `/etc/nixos/modules/nixos/services/ai/`:
- `default.nix`: System configuration (Ollama, Postgres, Timers).
- `scripts/`:
  - `echo-bridge.py`: The main terminal interface.
  - `database_manager.py`: SQL abstraction layer.
  - `export_training_data.py`: Dataset preparation.
  - `train_personality.py`: LoRA fine-tuning script.
- `training_shell.nix`: The ROCm training environment.

These files are symlinked to `~/projects/local-ai/` via Home Manager for easy access.

---

## 🔧 Hardware Optimization
Echo is optimized for **AMD RDNA3 (7900 XTX)**:
- **GFX Override**: `11.0.0` is set globally for AI tasks.
- **Quantization**: Training uses 4-bit `bitsandbytes` to stay within 24GB VRAM.
- **Acceleration**: Ollama is explicitly pinned to the `ollama-rocm` package.
