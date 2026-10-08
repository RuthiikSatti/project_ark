# ARK Network

## Remote Access Model

ARK is intended to be reachable from trusted devices without exposing unnecessary services directly to the public internet.

The current approach uses Tailscale as the private networking layer.

```text
Phone / Laptop
      │
      │ encrypted private connection
      ▼
  Tailscale Network
      │
      ▼
     ARK Host
```

## Tailscale

Tailscale creates a private network between enrolled devices. For ARK, this means a phone or laptop can reach the machine remotely as though the devices were connected to a private network, while avoiding traditional port-forwarding for routine administration.

## Remote Administration

The ARK machine is intended to operate headlessly rather than remain connected to a TV or monitor. Remote desktop access can be used for administration when a graphical Windows session is necessary.

The preferred architecture is:

1. Device connects to Tailscale.
2. Device reaches ARK over the private Tailscale network.
3. Remote administration or an application connection is established.
4. Docker services handle the application workload.

## Security Rules

- Do not commit Tailscale authentication keys or other credentials.
- Do not publish machine-specific private IP addresses in this repository.
- Avoid exposing Docker management interfaces directly to the public internet.
- Keep service credentials in environment files or another secret-management mechanism outside the public repository.

## Future Network Work

As ARK grows, the network layer will be revisited for:

- service-specific access controls
- backup connectivity
- local network performance
- monitoring
- additional trusted devices
