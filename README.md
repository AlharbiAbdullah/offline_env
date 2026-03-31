# Offline Development Environment

A fully offline development setup for an Ubuntu Linux laptop with local AI coding tools.

## Architecture

```
┌─────────────────────────────────────────────────┐
│               Ubuntu Linux Laptop                │
│                                                  │
│  ┌──────────────┐   ┌────────────────────────┐  │
│  │   Ollama     │   │      VS Code           │  │
│  │ (LLM Server) │◄──│  + Continue.dev        │  │
│  │ localhost:    │   │  (autocomplete + chat) │  │
│  │   11434      │   └────────────────────────┘  │
│  └──────┬───────┘                                │
│         │            ┌────────────────────────┐  │
│         ├───────────►│  OpenCode (CLI agent)  │  │
│         │            └────────────────────────┘  │
│         │            ┌────────────────────────┐  │
│         └───────────►│  Aider (CLI agent)     │  │
│                      └────────────────────────┘  │
│                                                  │
│  ┌──────────────┐   ┌────────────────────────┐  │
│  │   Docker     │   │  Open WebUI            │  │
│  │   Engine     │   │  (Chat interface)      │  │
│  └──────────────┘   └────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Hardware Requirements

> **IMPORTANT**: Update this section with actual laptop specs.

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM       | 16 GB   | 32+ GB     |
| GPU VRAM  | 6 GB    | 12+ GB     |
| Storage   | 100 GB free | 200+ GB free |
| GPU       | NVIDIA (CUDA) preferred | NVIDIA RTX 3060+ |

## Model Selection by Hardware

| RAM/VRAM | Coding Model | General/Reasoning Model |
|----------|-------------|------------------------|
| 8 GB     | qwen3.5:9b (6.6 GB) | qwen3:8b (5.2 GB) |
| 16-24 GB | qwen3.5:27b (17 GB) | qwen3:14b (9.3 GB) |
| 32+ GB   | qwen3-coder:30b (19 GB, MoE) | qwen3.5:27b (17 GB) |

### Model Notes
- **qwen3-coder:30b**: Best local coding model. MoE architecture, only 3.3B active params so it runs fast despite size. 256K context. Top SWE-bench scores.
- **qwen3.5:27b**: Strong all-around coding and reasoning. Has coding-specific variants.
- **qwen3.5:9b**: Best small model. Good for quick tasks or constrained hardware.
- **qwen3:8b/14b/30b**: General purpose with hybrid thinking mode.

## Components

### 1. Ollama (LLM Runtime)
Local model inference server. Runs models on your hardware.
- Install: `curl -fsSL https://ollama.com/install.sh | sh`
- See: `scripts/01_install_ollama.sh`

### 2. VS Code + Continue.dev (IDE)
Code editor with AI autocomplete and chat.
- See: `scripts/02_install_vscode.sh`
- Config: `configs/continue/config.json`

### 3. OpenCode (CLI Coding Agent)
Terminal-based AI coding assistant.
- See: `scripts/03_install_opencode.sh`
- Config: `configs/opencode/opencode.json`

### 4. Aider (CLI Coding Agent)
Battle-tested CLI coding agent with deep git integration.
- See: `scripts/04_install_aider.sh`

### 5. Docker Engine
Container runtime for development services.
- See: `scripts/05_install_docker.sh`

### 6. Open WebUI (Chat Interface)
ChatGPT-like web interface for Ollama models.
- See: `scripts/06_install_openwebui.sh`

### 7. Dev Tools (Languages, Package Managers)
Python 3.12, Node.js 20, Go, Git, uv, ripgrep, fd, jq.
- See: `scripts/07_install_devtools.sh`

## Setup Order

### Phase 1: Install (on Ubuntu laptop, while online)

```bash
./scripts/07_install_devtools.sh    # Python, Node, Go, Git first
./scripts/01_install_ollama.sh
./scripts/02_install_vscode.sh
./scripts/03_install_opencode.sh
./scripts/04_install_aider.sh
./scripts/05_install_docker.sh
./scripts/06_install_openwebui.sh
```

### Phase 2: Cache everything (while online)

```bash
# Pull LLM models
./scripts/08_pull_models.sh medium   # small | medium | large

# Cache Docker images as .tar files
./scripts/10_cache_docker_images.sh

# Cache Python packages as .whl files
# Edit requirements_offline.txt first to add your project's packages
./scripts/12_cache_python_packages.sh
```

### Phase 3: Verify

```bash
./scripts/09_verify_setup.sh
```

### On the Offline Laptop (if transferring via USB)

```bash
# Load Docker images from .tar files
./scripts/11_load_docker_images.sh

# Install Python packages from local .whl cache
./scripts/13_install_from_cache.sh
```

## Offline Dependency Strategy

### Problem
pip, npm, and docker all need internet by default.

### Solution: Pre-cache on an online machine, transfer via USB.

| Tool | Online (cache) | Offline (install) |
|------|---------------|-------------------|
| Python | `pip download` into `python_cache/` | `pip install --no-index --find-links=python_cache/` |
| Docker | `docker save` into `docker_cache/` | `docker load` from `.tar` files |
| Node | `npm pack` or copy `node_modules/` | `npm install --offline` |
| Ollama | `ollama pull` (stored in ~/.ollama) | Already local, just works |

### Adding new packages later
1. Edit `requirements_offline.txt` on an online machine
2. Re-run `./scripts/12_cache_python_packages.sh`
3. Copy the new `.whl` files to the offline laptop
4. Run `./scripts/13_install_from_cache.sh`

## Pre-Flight Checklist (Before Going Offline)

- [ ] All tools installed (09_verify_setup passes)
- [ ] Ollama models downloaded
- [ ] VS Code extensions installed
- [ ] Python packages cached in `python_cache/`
- [ ] Docker images cached in `docker_cache/`
- [ ] Git repos cloned
- [ ] Project-specific dependencies tested offline
