# Phase 3 — Private Cloud

Phase 3 moved ARK from Docker infrastructure experiments into a usable private cloud.

## Goal

Deploy Nextcloud with MariaDB, connect it to persistent Windows storage, and make it remotely accessible through the private Tailscale network.

## Architecture

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
    Docker
      │
      ├── Nextcloud
      │      │
      │      ▼
      │   C:\ARK\storage\nextcloud
      │
      └── MariaDB
             │
             ▼
          C:\ARK\storage\database
```

## What Was Built

- Nextcloud deployed with Docker Compose
- MariaDB deployed as the Nextcloud database service
- Nextcloud connected to MariaDB using the Docker service name `database`
- Nextcloud application data bind-mounted to `C:\ARK\storage\nextcloud`
- MariaDB data bind-mounted to `C:\ARK\storage\database`
- Nextcloud made reachable on port `8081`
- Tailscale used for private remote access
- Windows Firewall configured to allow TCP `8081` on the private Tailscale network profile
- Nextcloud trusted domain configured for the ARK Tailscale IP
- Nextcloud accessed successfully from both laptop and phone

## Persistence Test

A file created remotely from the laptop was verified directly on the ARK Windows filesystem under the Nextcloud data directory.

The same file remained available after restarting the Nextcloud and MariaDB containers.

This verified the intended chain:

```text
Remote device
    ↓
Tailscale
    ↓
Nextcloud
    ↓
Docker bind mount
    ↓
Windows filesystem
```

## Configuration and Security

Database credentials were initially used directly in the Compose file during setup. The configuration was then changed to environment-variable references:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```

Credentials are stored in a local `.env` file under `C:\ARK\services` rather than in the public repository.

The local `.gitignore` was also configured to exclude `.env`.

The public repository therefore documents the configuration pattern without publishing the actual credentials.

## Important Lessons

### Nextcloud is an application layer

Nextcloud provides the interface for managing files. It does not replace the underlying storage.

### MariaDB is a separate service

Nextcloud and its database run as separate containers and communicate over the Docker Compose network.

### Tailscale provides private connectivity

The ARK service does not need to be exposed directly to the public internet for remote access from trusted devices.

### Persistent storage is outside the container

The containers can be restarted or recreated while the important data remains on the Windows filesystem through bind mounts.

## Phase 3 Result

ARK now functions as a working private cloud accessible from multiple devices over the private network.

The next major infrastructure step is improving the storage layer before expanding into automation and other services.
