\# Phase 5 â€” Networking \& Automation



Phase 5 added automated maintenance, monitoring, recovery, notifications, and a WireGuard VPN to ARK.



\## 5.1 Automated Backups



ARK automatically backs up Nextcloud data and the MariaDB database.



\- PowerShell backup script

\- Timestamped backup directories

\- MariaDB database dump

\- Nextcloud file backup using Robocopy

\- Database backup verification

\- Robocopy exit-code verification

\- Daily scheduled backup at 3:00 AM

\- Telegram notification when a backup fails



Script:



`backup-nextcloud.ps1`



\## 5.2 Health Monitoring



ARK automatically checks its core infrastructure every five minutes.



Checks include:



\- External ARK storage availability

\- Docker availability

\- MariaDB health

\- Nextcloud container status

\- Nextcloud web-service response



Script:



`health-check.ps1`



\## 5.3 Automatic Service Recovery



When the health checker detects a recoverable service failure, ARK automatically attempts recovery.



Recovery can:



\- Restart MariaDB

\- Start a stopped Nextcloud container

\- Restart an unresponsive Nextcloud service

\- Verify that recovery succeeded



Automatic recovery is intentionally blocked when ARK storage or Docker is unavailable.



This prevents recovery attempts from making storage-related failures worse.



Script:



`service-recovery.ps1`



\### Recovery Test



Nextcloud was manually stopped.



The health checker detected the failure, invoked the recovery script, restarted Nextcloud, verified the web service, and returned ARK to a healthy state.



\## 5.4 Telegram Notifications



ARK uses a Telegram bot named BrainPunkBot as its notification interface.



Current notifications include:



\- Automatic service recovery

\- Critical infrastructure failures

\- Backup failures



Telegram credentials are stored locally and are excluded from Git.



BrainPunkBot is intended to become the communication interface for the Hermes Agent in a later phase.



Script:



`send-notification.ps1`



\## 5.5 WireGuard VPN



A WireGuard VPN was configured between ARK and a laptop.



VPN subnet:



`10.77.0.0/24`



ARK:



`10.77.0.1`



Laptop:



`10.77.0.2`



Verified:



\- WireGuard server running on ARK

\- Laptop peer configured

\- Successful cryptographic handshake

\- Encrypted traffic transfer

\- Successful ICMP communication

\- Nextcloud accessed through the WireGuard tunnel



Direct remote WireGuard access over the public Internet is postponed because ARK currently operates on an apartment-managed network where router port forwarding is not available.



Tailscale remains the primary remote-access fallback.



\## Security



Sensitive files are excluded from Git, including:



\- Environment files

\- Telegram credentials

\- WireGuard private keys

\- WireGuard configuration files

\- Backups

\- Live service data



No secrets should be committed to this repository.



\## Phase 5 Result



ARK can now:



1\. Back itself up automatically.

2\. Monitor its core services.

3\. Detect failures.

4\. Recover selected services automatically.

5\. Notify the administrator through Telegram.

6\. Provide encrypted local access through WireGuard.



Phase 5 establishes the automation and networking foundation required for the future ARK AI layer.
