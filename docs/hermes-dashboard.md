# Hermes Local Dashboard

Hermes has a local browser dashboard on ARK at `http://127.0.0.1:9119`.

The Docker container publishes the port only to the ARK machine's loopback interface. It shares the existing `hermes_data` volume with the Hermes gateway and uses password authentication. Dashboard credentials are intentionally not stored in this repository.

For remote access, use an authenticated reverse proxy or a Tailscale Serve configuration; do not expose port 9119 directly to the public internet.
