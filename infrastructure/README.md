# Infrastructure

This directory will contain deployment-related documentation and configuration for ARK services.

## Planned Organization

Service-specific infrastructure can be organized here as the project grows, for example:

```text
infrastructure/
├── portainer/
├── nextcloud/
├── automation/
└── ai/
```

Only configuration that is safe to publish should be committed. Secrets and machine-specific credentials belong outside the public repository.

The repository will document infrastructure changes as they are actually implemented rather than adding placeholder configurations for services that have not been deployed yet.
