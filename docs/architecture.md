# ARK Architecture

## Overview

ARK is designed as a layered self-hosted system. Each layer has a specific responsibility, which makes the infrastructure easier to understand, troubleshoot, and eventually migrate to better hardware.

```text
User Devices
     │
     ▼
 Tailscale
     │
     ▼
 ARK Host
     │
     ▼
 Windows / WSL2
     │
     ▼
 Docker Engine
     │
     ├── Portainer
     └── Application Containers
             │
             └── Persistent Storage
```

## Component Responsibilities

### Tailscale

Provides private network connectivity between trusted devices and ARK. It is the network path used for remote administration without needing to expose the management interface directly to the public internet.

### Windows / WSL2

The current ARK host uses Windows as the base operating system, with WSL2 providing the Linux environment required by the Docker setup.

### Docker

Docker runs applications as isolated containers. This gives each service a defined environment and makes services easier to replace or migrate later.

### Portainer

Portainer is the management layer for Docker. It provides a graphical interface for viewing containers, images, networks, volumes, logs, statistics, and deployments.

### Persistent Storage

ARK now uses a dedicated 1 TB external NTFS drive labeled `ARK Storage` as drive `D:`. Primary Nextcloud and MariaDB data has been migrated off the Windows system disk:

```text
D:\Services\Nextcloud
D:\Services\Database
```

The internal SSD holds a secondary backup baseline under `C:\ARK\Backups`, including a logical MariaDB dump and a copy of Nextcloud user data. This is a useful second copy but is not yet an independent disaster-recovery target because both drives remain attached to the same host.

## Current Container Networking

The current Compose services use a project network created automatically by Docker Compose:

```text
services_default
      │
      ├── web
      └── test-client
```

Containers on the same Compose network can communicate using service names. The current test environment verified both DNS resolution and HTTP communication from `test-client` to `web`.

## Example: Future Photo Flow

The planned private-cloud flow is:

```text
Phone
  │
  ▼
Nextcloud Mobile App
  │
  ▼
Tailscale
  │
  ▼
ARK
  │
  ▼
Docker / Nextcloud
  │
  ▼
D: ARK Storage
```

Other devices can then access the same files through Nextcloud without requiring every device to keep a complete local copy.

## Portability Goal

The application layer should remain as independent as possible from the physical machine. If ARK eventually moves to a larger server, the goal is to migrate storage and service configuration rather than redesign the entire system.


## Current Recovery Path

The Windows host starts Tailscale automatically and Docker Desktop is enabled in Windows Startup Apps. Nextcloud and MariaDB use the Docker restart policy `unless-stopped`. A reboot test verified that Docker, Portainer, MariaDB, and Nextcloud recover automatically once the Windows startup sequence completes.

The longer-term portability goal remains to keep service configuration and persistent data separable so the application layer can move to different hardware or a server-oriented operating system later.
