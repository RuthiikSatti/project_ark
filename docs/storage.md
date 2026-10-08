# ARK Storage

## Overview

ARK separates application containers from persistent data. Containers are replaceable runtime environments; persistent storage must live outside the container filesystem when data needs to survive container removal or recreation.

## Docker Volume vs Bind Mount

### Bind mount

A bind mount connects a specific directory on the host to a path inside a container.

```text
Windows host
C:\\ARK\\compose-test\\site
        │
        ▼
Container
/usr/share/nginx/html
```

The host controls the location. Changes made to the host directory are immediately visible to the container.

### Docker volume

A Docker volume is managed by Docker and mounted into a container.

```text
Docker-managed volume
ark_test_data
        │
        ▼
Container
/usr/share/nginx/html
```

The volume is separate from the container lifecycle, so its contents can survive container removal and recreation.

## Phase 1 Experiment

The first storage experiment used Docker Compose and two NGINX containers at the same time:

```text
                    Docker Compose
                         │
              ┌──────────┴──────────┐
              │                     │
        web container       volume-web container
              │                     │
         Bind mount            Docker volume
              │                     │
       C:\\ARK\\compose-test\\site    ark_test_data
              │                     │
      localhost:8081        localhost:8082
```

The bind-mounted NGINX service displayed the custom ARK webpage stored in the Windows `site` directory.

The volume-backed NGINX service exposed `volume-test.txt`, which contained:

```text
HELLO FROM DOCKER VOLUME
```

Both services ran simultaneously, demonstrating that Docker can use different persistent-storage mechanisms at the same time.

## Compose External Volume Lesson

An initially created Docker volume named `ark_test_data` was different from the automatically generated Compose volume `compose-test_ark_test_data`.

The Compose configuration was then changed to explicitly reference the existing volume:

```yaml
volumes:
  ark_test_data:
    external: true
```

This prevented Compose from creating another project-scoped copy and connected the service to the intended volume.

## Persistence Test

The containers were stopped and removed with `docker compose down`. The `ark_test_data` volume was not removed.

After the containers were gone, the file was read directly from the volume and still returned:

```text
HELLO FROM DOCKER VOLUME
```

This confirmed the key Docker storage principle:

> Container lifecycle and persistent storage lifecycle are separate.

## ARK Design Implication

Future ARK services should separate application/system data from user data.

```text
ARK
│
├── Docker-managed data
│   └── Application/system state
│
└── Physical ARK storage
    ├── Personal
    ├── Career & Education
    ├── Projects
    ├── Media
    ├── Archive
    └── Backups
```

Applications such as Nextcloud may have access to selected persistent storage, but mounted storage is not automatically exposed through the application's user interface. The application must be configured to use and expose the storage intentionally.

## Lesson Learned

**A container is the application runtime. Persistent storage is a separate concern.**

Understanding this separation is foundational to ARK's future Nextcloud, backup, automation, and migration architecture.
