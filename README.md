# Offline Development Environment

A fully offline development setup for a Linux laptop with local AI coding tools.

Supported distributions:
- **Ubuntu 24.04 LTS** (original target)
- **Omarchy / Arch Linux** (via `pacman` + `yay`)

All install scripts auto-detect the distro from `/etc/os-release` and use the
appropriate package manager.

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

## Hardware

| Component | Spec |
|-----------|------|
| Machine   | ASUS ROG Strix G16 (G614JIR) |
| CPU       | Intel Core i9-14900HX (24 cores) |
| RAM       | 32 GB |
| GPU       | NVIDIA RTX 4070 (8 GB VRAM) |
| Storage   | 1 TB |
| OS        | Ubuntu 24.04 LTS |

## Models (Qwen 3.5 family only)

| Model | Size | Role | Speed |
|-------|------|------|-------|
| qwen3.5:4b | 3.4 GB | Fast reasoning, quick questions | Fast (fits GPU) |
| qwen3.5:9b | 6.6 GB | Fast coding, autocomplete | Fast (fits GPU) |
| qwen3.5:35b | 24 GB | Best coding + reasoning | Slow (mostly CPU) |
| nomic-embed-text | 274 MB | Embeddings for search/RAG | Instant |

Total disk: ~34 GB. No accounts required. All inference runs locally via Ollama.

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

### 6. Dev Tools (Languages, Package Managers)
Python 3.12, Node.js 22 LTS, Git, uv, ripgrep, fd, jq.
- See: `scripts/07_install_devtools.sh`

## Setup Order

### Phase 1: Install (while online)

Run these on Ubuntu **or** Omarchy/Arch — each script detects the distro
automatically.

```bash
./scripts/07_install_devtools.sh    # Python, Node, Git, uv first
./scripts/01_install_ollama.sh
./scripts/02_install_vscode.sh
./scripts/03_install_opencode.sh
./scripts/04_install_aider.sh
./scripts/05_install_docker.sh      # Ubuntu only (not yet ported to Arch)
```

#### Omarchy / Arch notes

- VS Code is installed via the AUR package `visual-studio-code-bin` using the
  `yay` helper that ships with Omarchy. If `yay` is missing, the script falls
  back to the `code` (OSS) package from the `extra` repo — but that build
  cannot install Microsoft-marketplace extensions.
- `ollama` is installed via `pacman` (prefers `ollama-cuda` if an NVIDIA GPU
  is detected) and the systemd unit is enabled.
- `pipx` is installed via `pacman` as `python-pipx`.
- After running the scripts, open a new shell (or `source ~/.bashrc`) so
  `~/.local/bin` is on `PATH` — that's where `pipx` puts `aider` and the
  OpenCode installer puts `opencode`.

### Phase 2: Cache everything (while online)

```bash
# Pull LLM models
./scripts/08_pull_models.sh

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

## USB Supply Chain (Adding Things After Going Offline)

The air-gapped laptop never goes online. All updates come via USB from any online machine.

```
┌──────────────┐      USB Drive      ┌──────────────────┐
│ Online       │  ──────────────►    │ Air-Gapped       │
│ Machine      │   offline_env/      │ Laptop           │
│ (any laptop, │   ├── python/       │ (sensitive data, │
│  cafe wifi,  │   ├── ollama/       │  never online)   │
│  phone)      │   ├── docker/       │                  │
│              │   └── vscode/       │                  │
└──────────────┘                     └──────────────────┘
  usb_prepare.sh                       usb_install.sh
```

### On the online machine (prepare USB):

```bash
# Need a Python library
./usb_prepare.sh /media/usb python requests httpx sqlalchemy

# Need a new Ollama model
./usb_prepare.sh /media/usb ollama qwen3-coder:30b

# Need a Docker image
./usb_prepare.sh /media/usb docker postgres:16-alpine

# Need a VS Code extension
./usb_prepare.sh /media/usb vscode ms-python.python
```

### On the air-gapped laptop (install from USB):

```bash
# Install everything on the USB
./usb_install.sh /media/usb all

# Or install specific types
./usb_install.sh /media/usb python
./usb_install.sh /media/usb ollama
./usb_install.sh /media/usb docker
```

### Notes
- The online machine does NOT need to be your machine. Any computer with internet works.
- Ollama must be installed on the online machine to pull models.
- Docker must be installed on the online machine to pull images.
- Python packages are downloaded as wheels. Platform-specific for Linux x86_64.

## Pre-Flight Checklist (Before Going Offline)

- [ ] All tools installed (09_verify_setup passes)
- [ ] Ollama models downloaded
- [ ] VS Code extensions installed
- [ ] Python packages cached in `python_cache/`
- [ ] Docker images cached in `docker_cache/`
- [ ] Git repos cloned
- [ ] Project-specific dependencies tested offline
