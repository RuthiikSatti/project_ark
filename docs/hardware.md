# ARK Hardware

## Current System

ARK is currently running on a mini PC intended to serve as a headless personal infrastructure host.

The current environment has:

- 1 TB of available storage hardware
- 12 CPU cores reported by the Docker/Portainer environment
- Approximately 16.5 GB of memory reported by Portainer
- Windows as the host operating system
- WSL2 supporting the Linux/Docker environment

Exact hardware model details are intentionally not recorded here until they are verified.

## Current Hardware Role

The machine currently acts as the foundation for:

- Docker workloads
- Portainer management
- Remote administration
- Future private-cloud services

## Storage Strategy

The current 1 TB drive is suitable for building and testing the initial infrastructure. It is not intended to define the final storage architecture.

As ARK grows, the plan is to move toward larger storage capacity and a more deliberate backup strategy.

## Upgrade Philosophy

Future hardware should improve capacity and reliability without requiring a complete redesign of the application layer.

The preferred migration model is:

```text
Current Mini PC
      │
      │ migrate services + data
      ▼
Larger / More Capable Server
```

The physical hardware can change while the logical architecture remains familiar.
