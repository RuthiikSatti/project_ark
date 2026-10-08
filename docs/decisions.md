# ARK Architecture Decisions

This document records why major infrastructure choices were made. Decisions can be changed as the project develops.

## Docker

**Decision:** Use Docker as the primary application runtime.

**Why:** Services can run in isolated environments, can be managed independently, and are easier to migrate between machines than applications installed directly into the host operating system.

## Portainer

**Decision:** Use Portainer as the primary Docker management interface during the initial build.

**Why:** It provides a visual way to understand Docker while still allowing the underlying concepts to be learned. It is useful for inspecting containers, images, networks, volumes, logs, and resource usage.

## Tailscale

**Decision:** Use Tailscale for private remote connectivity.

**Why:** ARK needs to be accessible from trusted devices while avoiding unnecessary public exposure and traditional port-forwarding for routine remote access.

## Windows + WSL2

**Decision:** Keep the current Windows-based host while building the first version of ARK.

**Why:** It allows the project to use existing hardware and provides a practical environment for learning Docker and Linux-based infrastructure through WSL2. The architecture can be migrated later if a dedicated Linux server becomes preferable.

## Nextcloud

**Decision:** Nextcloud is the planned private-cloud application layer.

**Why:** The project needs a central place for personal files and photos that can be accessed across devices while keeping the underlying storage under the user's control.

## Public GitHub Repository

**Decision:** Keep the project documentation public.

**Why:** ARK is also a portfolio and learning project. Public documentation makes the engineering process visible and provides a record of real infrastructure work.

**Constraint:** Secrets, credentials, private keys, authentication tokens, and machine-specific sensitive information must stay out of the repository.

## Core Principle

The architecture should optimize for **understanding, security, portability, and incremental growth** rather than maximizing complexity from the beginning.
