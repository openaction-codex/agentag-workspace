# OpenAction agent workspace environment

This repository contains the OpenAction Agent workspace environment (provisioning, skills, sub agents, ...). 

## Supported system

- Ubuntu 26.04 LTS (Resolute)
- A root shell, or a regular login user with `sudo` access
- An interactive terminal and outbound internet access

## Provision the VPS

Clone the repository as the user that will run Codex, then run:

```bash
./bin/provision.sh
```

## Finish the setup

Reconnect over SSH (or start a new login shell) so the MetaMCP environment variable and, for non-root users, 
Docker group membership take effect. 

Then authenticate Codex:

```bash
codex login
```
