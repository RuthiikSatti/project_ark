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
      └── Application Containers
            ├── Nextcloud
            ├── Automation (planned)
            └── AI Assistant (planned)
      │
      ▼
 D: ARK Storage (1 TB NTFS)
      │
      ├── Services / Nextcloud
      └── Services / Database
```

## What Has Been Built

- Remote administration of the ARK machine
- Tailscale configured for private remote connectivity
- Windows Subsystem for Linux (WSL2) repaired/configured for the Docker environment
- Docker installed and verified with a successful container test
- Portainer deployed as the Docker management interface
- NGINX Compose services deployed and accessed successfully
- Docker bind mount and volume storage mechanisms tested side-by-side
- Docker volume persistence verified across container removal and recreation
- Multi-container Docker networking and service-name DNS verified
- Container-to-container HTTP communication verified
- Environment-variable configuration verified inside a running container
- Compose restart and recovery verified
- Nextcloud deployed with MariaDB
- Nextcloud connected to persistent Windows storage
- Private remote Nextcloud access verified from laptop and phone through Tailscale
- Remote file persistence verified across container restart
- Local `.env` configuration and `.gitignore` protection added for database credentials
- Dedicated 1 TB NTFS ARK storage drive added and structured
- Nextcloud and MariaDB persistent data migrated to the dedicated storage drive
- Nextcloud permissions repaired and application health verified after migration
- Automatic restart configured for Nextcloud and MariaDB
- Docker Desktop startup and full reboot recovery verified
- Initial Nextcloud database and file backups created on the internal SSD
- Initial architecture and infrastructure decisions documented

## What ARK Is Becoming

ARK is being built in stages:

1. **Foundation** — hardware, operating system, networking, and remote access
2. **Containerization** — Docker and service management
3. **Private Cloud** — Nextcloud for files and photos
4. **Storage** — dedicated 1 TB storage, migration, recovery, and backup baseline **(completed)**
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
│   ├── phase-2.md
│   ├── phase-3.md
│   ├── phase-4.md
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
