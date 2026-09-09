# Project ARK

**ARK (Autonomous Remote Kernel)** is a personal self-hosted infrastructure project built from a mini PC and designed to become a private, portable, and scalable digital environment.

The goal is to build the system from the ground up, understand every layer, document the decisions, and eventually expand it into a personal cloud, automation platform, and AI-assisted home lab.

## Current Architecture

```text
Phone / Laptop
      │
      ▼
   Tailscale
      │
      ▼
     ARK
      │
      ▼
   Windows
      │
      ▼
    Docker
      │
      ├── Portainer
      └── Future Services
            ├── Nextcloud
            ├── Automation
            └── AI Assistant
      │
      ▼
   Local Storage
```

## What Has Been Built

- Remote administration of the ARK machine
- Tailscale configured for private remote connectivity
- Windows Subsystem for Linux (WSL2) repaired/configured for the Docker environment
- Docker installed and verified with a successful container test
- Portainer deployed as the Docker management interface
- First NGINX container/stack deployed and accessed successfully from multiple devices
- Docker bind mount and volume storage mechanisms tested side-by-side
- Docker volume persistence verified across container removal and recreation
- Initial architecture and infrastructure decisions documented

## What ARK Is Becoming

ARK is being built in stages:

1. **Foundation** — hardware, operating system, networking, and remote access
2. **Containerization** — Docker and service management
3. **Private Cloud** — Nextcloud for files and photos
4. **Storage** — larger and more resilient storage as the hardware evolves
5. **Automation** — scheduled tasks and personal workflows
6. **AI Layer** — a persistent personal AI assistant running on the infrastructure
7. **Scalability** — migrate services to stronger hardware without rebuilding the entire architecture

## Design Principles

### Learn before abstracting

ARK is intentionally being built while learning the underlying technologies. The objective is not simply to make services work, but to understand why they work.

### Private by default

Remote access should use secure private networking rather than exposing unnecessary services directly to the public internet.

### Portable architecture

Services should be separated from the underlying hardware wherever practical so ARK can move from the current machine to future hardware with minimal redesign.

### Document the real work

This repository records actual infrastructure changes, decisions, experiments, and lessons learned. It is not intended to manufacture activity or simulate progress.

## Repository Structure

```text
project_ark/
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── decisions.md
│   ├── hardware.md
│   ├── network.md
│   └── storage.md
├── infrastructure/
│   └── README.md
└── scripts/
    └── README.md
```

## Security

Secrets, credentials, private keys, environment files, and machine-specific sensitive configuration should never be committed to this public repository.

## Project Philosophy

**Learn → Build → Document → Improve → Scale**
