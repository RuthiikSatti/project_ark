\# Phase 6 — Hermes Agent



\## Overview



Phase 6 integrated Hermes Agent into ARK as the primary autonomous operations assistant.



Hermes is accessible through BrainPunkBot on Telegram and can monitor, diagnose, maintain, and recover ARK while operating under enforced safety controls.



Phase 6 established:



\- Persistent Hermes Agent deployment

\- Telegram integration through BrainPunkBot

\- ARK-specific identity and operational context

\- Docker visibility and control

\- Secure SSH access from Hermes to the Windows host

\- Windows PowerShell automation access

\- ARK Operations skill

\- Backup and recovery capabilities

\- Enforced permission and approval rules

\- End-to-end autonomous recovery



\---



\## Architecture



```text

Ruthiik

&#x20;  |

&#x20;  v

BrainPunkBot (Telegram)

&#x20;  |

&#x20;  v

Hermes Agent

&#x20;  |

&#x20;  +---- Docker Socket ----> Docker / Containers

&#x20;  |

&#x20;  +---- SSH -------------> Windows 11 ARK Host

&#x20;                               |

&#x20;                               +--> Health Monitoring

&#x20;                               +--> Backup Scripts

&#x20;                               +--> Recovery Scripts

&#x20;                               +--> Storage Checks

&#x20;                               +--> ARK Automation

```



Hermes runs as a persistent Docker container with persistent storage, Docker access, automatic restart, Telegram connectivity, and ARK-specific configuration.



\---



\## ARK Identity



Hermes recognizes ARK as \*\*Autonomous Remote Kernel\*\*, Ruthiik's self-hosted infrastructure server.



Hermes understands its role as ARK's primary autonomous operations assistant and recognizes the core services:



\- Docker

\- Nextcloud

\- MariaDB

\- Portainer

\- Tailscale

\- WireGuard

\- BrainPunkBot

\- ARK backup and monitoring automation



A stale Telegram session initially prevented updated ARK identity information from loading. Starting a fresh Hermes session resolved the issue.



\---



\## Docker Integration



Hermes accesses the Docker daemon through the Docker socket.



This allows Hermes to:



\- List containers

\- Inspect containers

\- Read logs

\- Diagnose container health

\- Start or restart authorized services

\- Verify service recovery



Docker socket access is highly privileged and is therefore protected by ARK's permission and approval system.



\---



\## Windows Host Control



Hermes connects from its Docker container to the Windows ARK host using OpenSSH.



```text

Hermes Container

&#x20;     |

&#x20;     | SSH

&#x20;     v

host.docker.internal

&#x20;     |

&#x20;     v

Windows 11 ARK Host

```



Authentication uses a dedicated SSH key stored in Hermes persistent storage.



Private keys, credentials, tokens, and other secrets are intentionally excluded from the public repository.



The SSH bridge allows Hermes to execute existing ARK PowerShell automation without exposing Windows credentials through Telegram.



\---



\## ARK Operations Skill



A local Hermes skill named `ark-operations` provides operational guidance for:



\- ARK health checks

\- Storage checks

\- Docker monitoring

\- Backup execution

\- Service recovery

\- Windows PowerShell automation

\- Post-operation verification



A separate `ark-docker-operations` skill handles detailed Docker-specific procedures.



The operating principle is:



```text

Understand

&#x20;  ↓

Diagnose

&#x20;  ↓

Choose least-invasive action

&#x20;  ↓

Verify authorization

&#x20;  ↓

Execute

&#x20;  ↓

Verify result

&#x20;  ↓

Report

```



\---



\## Backup Integration



Hermes can execute ARK's existing backup automation through the Windows SSH bridge.



A successful Hermes-triggered backup verified:



\- MariaDB database dump

\- Nextcloud file backup

\- Backup directory creation

\- Successful script completion



Backups remain managed by ARK's existing PowerShell automation rather than being reimplemented inside Hermes.



\---



\## Recovery Integration



Hermes can invoke ARK's existing recovery procedure when recovery is authorized.



The recovery system checks:



\- ARK storage availability

\- Docker availability

\- MariaDB health

\- Nextcloud container state

\- Nextcloud web availability



Recovery is scoped to the affected service whenever possible.



\---



\## Permission Model



ARK uses three operational permission levels.



\### Level 1 — Autonomous



Read-only operations can run automatically.



Examples:



\- Health checks

\- Storage checks

\- `docker ps`

\- Docker inspection

\- Docker logs

\- Application status checks

\- Diagnostics

\- Verification



\### Level 2 — Explicit Request Required



These operations require explicit authorization in the current request.



Examples:



\- Run an ARK backup

\- Run existing ARK recovery

\- Restart a specifically requested service

\- Start or stop a specifically requested service

\- Execute an existing maintenance procedure matching the request



\### Level 3 — Confirmation Required



High-risk operations require additional human approval immediately before execution.



Examples:



\- Remove containers

\- Recreate containers

\- Remove Docker images

\- Other potentially destructive infrastructure operations



\---



\## Enforced Safety Controls



Prompt instructions alone were tested and found insufficient for destructive-operation protection.



ARK therefore uses technical enforcement in addition to AI instructions.



\### Hard Deny



Selected extremely destructive Docker commands are blocked through Hermes's native approval deny configuration.



Examples include:



```text

docker volume rm

docker volume prune

docker system prune

docker builder prune

docker image prune

docker network prune

```



These commands cannot be authorized through the normal agent approval flow.



\### Human Approval



The `custom-dangerous-patterns` Hermes plugin provides an approval gate for high-risk but potentially legitimate operations.



Protected operations currently include:



```text

docker rm

docker compose rm

```



When Hermes attempts one of these operations, execution pauses and BrainPunkBot requests human approval.



If no response is received before the approval timeout, the command does not execute.



The approval system was tested using a disposable Docker container. Hermes successfully paused before deletion, requested approval through Telegram, and executed the deletion only after approval.



\---



\## Safety Model



```text

Read-only operation

&#x20;       |

&#x20;       v

&#x20;     ALLOW





Authorized maintenance

&#x20;       |

&#x20;       v

&#x20;    EXECUTE





High-risk operation

&#x20;       |

&#x20;       v

&#x20;      ASK

&#x20;       |

&#x20;  Human Approval

&#x20;    /       \\

&#x20;Approve     Deny

&#x20;   |          |

&#x20;Execute      Stop





Extremely destructive operation

&#x20;       |

&#x20;       v

&#x20;     DENY

```



\---



\## End-to-End Validation



Phase 6 concluded with a controlled autonomous recovery test.



Nextcloud was intentionally stopped.



Hermes was then asked to diagnose ARK and recover the system if necessary.



Hermes correctly determined:



\- Docker was running

\- MariaDB was healthy

\- Nextcloud was stopped

\- Nextcloud's web endpoint was unavailable



Hermes executed ARK's existing recovery procedure.



The recovery process:



1\. Confirmed ARK storage availability

2\. Confirmed Docker availability

3\. Confirmed MariaDB was healthy

4\. Avoided restarting MariaDB unnecessarily

5\. Started only Nextcloud

6\. Sent the ARK recovery notification

7\. Verified Nextcloud after recovery



Final verification confirmed:



\- Nextcloud container running

\- Nextcloud `/status.php` returned HTTP 200

\- Maintenance mode disabled

\- No database upgrade required

\- No unrelated services modified



The complete path was successfully validated:



```text

Telegram

&#x20;  ↓

BrainPunkBot

&#x20;  ↓

Hermes

&#x20;  ↓

Diagnosis

&#x20;  ↓

Windows SSH / Docker

&#x20;  ↓

ARK Recovery Automation

&#x20;  ↓

Service Recovery

&#x20;  ↓

Verification

&#x20;  ↓

Telegram Notification

```



\---



\## Phase 6 Result



Phase 6 transformed Hermes from a standalone AI agent into an operational control layer for ARK.



Completed capabilities:



\- Persistent AI agent

\- Telegram control interface

\- ARK-aware identity

\- Docker monitoring and control

\- Windows host access

\- PowerShell automation

\- Backup execution

\- Autonomous diagnosis

\- Controlled recovery

\- Human approval gates

\- Hard destructive-command protection

\- End-to-end autonomous recovery



\*\*Phase 6 Status: COMPLETE\*\*

