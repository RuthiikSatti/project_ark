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

Application data needs to live outside disposable containers. The current system has a 1 TB storage drive, with larger storage planned as the infrastructure grows.

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
Persistent Storage
```

Other devices can then access the same files through Nextcloud without requiring every device to keep a complete local copy.

## Portability Goal

The application layer should remain as independent as possible from the physical machine. If ARK eventually moves to a larger server, the goal is to migrate storage and service configuration rather than redesign the entire system.
