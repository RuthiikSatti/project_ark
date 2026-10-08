# Phase 4 — Storage and Recovery

Phase 4 moved ARK from using the internal system SSD for application data to a dedicated external storage layer, then verified persistence, remote access, restart recovery, and basic backups.

## Goal

Add dedicated storage for ARK, migrate the existing Nextcloud stack without losing data, and improve recovery behavior after a Windows reboot.

## Storage Layout

The external 1 TB drive was reformatted from exFAT to NTFS and labeled `ARK Storage` as drive `D:`.

```text
D:\
├── Personal
├── Career & Education
├── Projects
├── Media
├── Archive
├── Backups
└── Services
    ├── Nextcloud
    └── Database
```

The general-purpose folders establish the future ARK storage layout. Application data is isolated under `D:\Services`.

## Service Migration

The existing persistent data was copied while the Compose stack was stopped:

```text
C:\ARK\storage\nextcloud  → D:\Services\Nextcloud
C:\ARK\storage\database   → D:\Services\Database
```

Robocopy completed both migrations with zero failed files. The original copies on `C:` were intentionally retained temporarily as a rollback point.

The Compose bind mounts were then updated so Nextcloud and MariaDB use the new locations on `D:`.

## Nextcloud Permission Recovery

After migration, Apache started but Nextcloud returned HTTP 503. The database was healthy, but Nextcloud rejected the data directory because the permissions presented through the Windows bind mount were not appropriate.

The data directory was corrected to:

```text
/var/www/html/data
owner: www-data
group: www-data
mode: 0770
```

Nextcloud was then verified with `occ status`:

- installed: true
- maintenance: false
- database upgrade: not required

Remote access and file visibility were verified again from both laptop and phone over Tailscale.

## Restart and Recovery

A real Windows reboot was used to test the recovery chain.

Tailscale was configured as an automatic Windows service. Docker Desktop was enabled in Windows Startup Apps. The Nextcloud and MariaDB Compose services were configured with:

```yaml
restart: unless-stopped
```

After reboot, Docker started and the following containers recovered automatically:

- Nextcloud
- MariaDB
- Portainer

This verified the current recovery path:

```text
Windows startup
      ↓
Tailscale + Docker Desktop
      ↓
Docker Engine
      ↓
MariaDB + Nextcloud + Portainer
      ↓
D:\ ARK Storage
```

## Backup Baseline

A dedicated backup directory exists at:

```text
C:\ARK\Backups
```

The first database backup was created as a logical MariaDB dump:

```text
C:\ARK\Backups\nextcloud-db.sql
```

The first dump was approximately 1.5 MB.

Nextcloud user data was also copied to:

```text
C:\ARK\Backups\nextcloud-files
```

The file backup completed with zero failures.

## Backup Limitation

The internal SSD backup is a second copy, but it is not a complete disaster-recovery strategy. The internal SSD and external drive are attached to the same ARK machine, so theft, electrical damage, or loss of the entire host could affect both.

A future phase should add another independent backup target such as a second physical disk, NAS, or off-site destination.

## Phase 4 Result

ARK now has a dedicated 1 TB storage layer, migrated persistent Nextcloud and MariaDB data, verified remote read/write access, automatic container recovery after reboot, and a basic secondary backup on the internal SSD.

The storage layer is now ready to support later automation and AI services without keeping primary application data on the Windows system disk.
