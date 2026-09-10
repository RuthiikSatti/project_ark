# Phase 2 — Containerized Service Management

## Objective

Phase 2 moved ARK from a basic Docker installation to a small multi-container Compose system that can communicate, receive configuration, and recover after restart.

## Project

Compose project location:

```text
C:\ARK\services
```

Compose file:

```text
C:\ARK\services\compose.yaml
```

Current services:

- `web` — `nginx:alpine`
- `test-client` — `alpine`

## Deployment

The Compose project was validated and deployed with Docker Compose.

The `web` service publishes container port 80 to host port 8080:

```text
Windows host :8080
      │
      ▼
  web container :80
      │
      ▼
    NGINX
```

The NGINX default page was successfully accessed from the host browser.

## Container Networking

Docker Compose automatically created the project network:

```text
services_default
      │
      ├── web
      └── test-client
```

The network uses Docker's bridge networking and provides service-name DNS.

The `test-client` container successfully resolved the `web` service name and reached it at its Docker network address.

## Container-to-Container Communication

Network reachability was tested with:

```powershell
docker compose exec test-client ping -c 3 web
```

The test returned 0% packet loss.

Actual HTTP communication was then verified with:

```powershell
docker compose exec test-client wget -qO- http://web
```

The request returned the NGINX HTML page.

This demonstrated that containers can communicate using the Compose service name instead of relying on a hard-coded container IP address.

## Environment Configuration

The `test-client` service was configured with:

```yaml
environment:
  ARK_MODE: learning
```

The running container was queried and returned:

```text
learning
```

This verified that configuration defined in Compose was passed into the running container.

## Restart and Recovery Test

The complete Compose project was restarted with:

```powershell
docker compose restart
```

Both containers restarted successfully.

The final status check with:

```powershell
docker compose ps
```

showed both services in an `Up` state.

## Phase 2 Lessons

1. Docker Compose creates a project network automatically.
2. Containers on the same Compose network can communicate using service names.
3. DNS-based service discovery avoids depending on changing container IP addresses.
4. Environment variables allow runtime configuration without rebuilding an image.
5. A Compose restart can recover the running services without recreating the project manually.
6. Portainer provides a graphical view of the same containers and network managed through Docker Compose.

## Phase 2 Status

**Complete.**

The next phase can build on this foundation by introducing a real multi-service application and persistent storage rather than test containers.
