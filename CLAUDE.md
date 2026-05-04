# ansible-playbook — CLAUDE.md

AI assistant guide for the OpenGreenhouseManager infrastructure automation.

## Overview

Ansible playbooks and roles for provisioning and deploying the full OpenGreenhouseManager stack across staging and production environments. Manages infrastructure setup (Docker, PostgreSQL, monitoring) as well as application deployment.

## Technology Stack

- **Automation**: Ansible
- **Pre-commit validation**: pre-commit framework (see `.pre-commit-config.yaml`)
- **Galaxy dependencies**: `requirements.yml`
- **Environments**: staging (single host), production (multi-host)

## Repository Layout

```
ansible-playbook/
├── ansible.cfg                 # Ansible configuration (roles_path, host_key_checking)
├── requirements.yml            # Ansible Galaxy role/collection dependencies
├── .pre-commit-config.yaml     # Pre-commit hook configuration
├── playbooks/
│   ├── staging.yml             # Full-stack deployment for staging
│   └── production.yml          # Full-stack deployment for production
├── inventory/
│   ├── staging/
│   │   ├── hosts.yml           # Staging host definitions and group assignments
│   │   └── group_vars/         # Variables scoped to staging groups
│   └── production/
│       ├── hosts.yml           # Production host definitions
│       └── group_vars/         # Variables scoped to production groups
├── roles/
│   ├── docker_setup/           # Install and configure Docker engine
│   ├── node_exporter/          # Prometheus node exporter for host metrics
│   ├── postgres/               # PostgreSQL database setup
│   ├── prometheus/             # Prometheus metrics collection
│   ├── grafana/                # Grafana dashboards
│   ├── loki/                   # Loki log aggregation
│   ├── opengreenhousemanager/  # Deploy backend services via Docker
│   ├── angular_web/            # Deploy the Angular frontend
│   ├── greenhouse_input_alert_trigger/   # Example device: alert trigger
│   ├── greenhouse_input_output_saver/    # Example device: I/O data saver
│   └── greenhouse_periodic_alert/        # Example device: periodic alert
└── hooks/                      # Local git hooks
```

### Role structure (standard Ansible layout)

```
roles/<name>/
├── tasks/
│   └── main.yml        # Task definitions
├── handlers/
│   └── main.yml        # Handlers (e.g. restart service)
├── templates/          # Jinja2 templates (.j2)
├── files/              # Static files to copy
├── vars/               # Role-internal variables
└── defaults/           # Default variable values
```

## Playbooks

### `playbooks/staging.yml`

Deploys everything to a single host. Suitable for local/development validation.

```
1. Setup docker          → docker_setup, node_exporter, postgres,
                           prometheus, grafana, loki   (hosts: all)
2. Setup greenhouse services → greenhouse_input_alert_trigger,
                               greenhouse_input_output_saver,
                               greenhouse_periodic_alert  (hosts: all)
3. Setup application     → opengreenhousemanager, angular_web
                           (hosts: opengreenhousemanager)
```

### `playbooks/production.yml`

Deploys across dedicated host groups. Infrastructure concerns are separated.

```
1. Setup docker          → docker_setup, node_exporter              (hosts: all)
2. Setup database        → postgres                                  (hosts: database)
3. Setup monitoring      → prometheus, grafana, loki                 (hosts: monitoring)
4. Setup greenhouse services → input_alert_trigger, input_output_saver,
                               periodic_alert                        (hosts: all)
5. Setup application     → opengreenhousemanager, angular_web        (hosts: all)
```

## Inventory

### Staging (`inventory/staging/hosts.yml`)

All services run on a single host. Host groups (`database`, `monitoring`, `opengreenhousemanager`) all resolve to the same machine.

```yaml
all:
  children:
    database:
      hosts:
        staging-all: { ansible_host: 192.168.178.96, ansible_user: maudi }
    monitoring:
      hosts:
        staging-all: { ansible_host: 192.168.178.96, ansible_user: maudi }
    opengreenhousemanager:
      hosts:
        staging-all: { ansible_host: 192.168.178.96, ansible_user: maudi }
```

### Production (`inventory/production/`)

Uses separate hosts for `database`, `monitoring`, and application tiers. Define actual hostnames/IPs in `inventory/production/hosts.yml` and secrets in `inventory/production/group_vars/`.

## Running Playbooks

```bash
# Install Galaxy dependencies first
ansible-galaxy install -r requirements.yml

# Run staging deployment
ansible-playbook -i inventory/staging playbooks/staging.yml

# Run production deployment
ansible-playbook -i inventory/production playbooks/production.yml

# Dry-run (check mode)
ansible-playbook -i inventory/staging playbooks/staging.yml --check

# Run only specific roles/tags
ansible-playbook -i inventory/staging playbooks/staging.yml --tags docker_setup

# Limit to a specific host
ansible-playbook -i inventory/production playbooks/production.yml --limit database
```

## Roles Reference

| Role | Purpose |
|------|---------|
| `docker_setup` | Installs Docker Engine and Docker Compose plugin |
| `node_exporter` | Deploys Prometheus node exporter for host-level metrics |
| `postgres` | Deploys PostgreSQL container with initial DB schema |
| `prometheus` | Deploys Prometheus for metrics scraping |
| `grafana` | Deploys Grafana with pre-configured dashboards |
| `loki` | Deploys Grafana Loki for log aggregation |
| `opengreenhousemanager` | Pulls and runs backend service images from `ghcr.io` |
| `angular_web` | Deploys the Angular frontend (nginx container) |
| `greenhouse_input_alert_trigger` | Deploys example alert-trigger device |
| `greenhouse_input_output_saver` | Deploys example I/O data saver device |
| `greenhouse_periodic_alert` | Deploys example periodic alert device |

## Configuration and Secrets

- **Group variables** for each environment live in `inventory/<env>/group_vars/`.
- Sensitive values (passwords, tokens, image tags) should use **Ansible Vault** for encryption.
- Never commit unencrypted secrets. Encrypt with: `ansible-vault encrypt_string '<secret>' --name '<var_name>'`
- The `opengreenhousemanager` role uses Docker image tags from `ghcr.io/opengreenhousemanager/` — set the desired image tag via group variables.

## Code Conventions

### YAML style

- Indent with 2 spaces.
- Quote strings that contain special characters or Jinja2 expressions.
- Use `name:` on every task with a descriptive, imperative sentence.
- Prefer `block:` + `rescue:` for error handling over bare `ignore_errors`.

### Role design

- Keep roles single-purpose and idempotent — running a playbook twice must not cause changes on the second run.
- Use `handlers` for service restarts rather than tasks with `notify`.
- Store role-specific defaults in `defaults/main.yml` so they can be overridden by inventory vars.
- Use Jinja2 templates (`.j2`) for configuration files that vary between environments.

### Pre-commit hooks

Install and run pre-commit before pushing:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files   # manual run
```

The `.pre-commit-config.yaml` validates YAML syntax and Ansible lint rules.

## Adding a New Role

1. Create the directory `roles/<new_role>/tasks/main.yml` (and other standard subdirectories as needed).
2. Add the role to the relevant playbook(s) (`playbooks/staging.yml` and/or `playbooks/production.yml`) under the appropriate play.
3. Add default variables to `roles/<new_role>/defaults/main.yml`.
4. Document any required inventory variables in the role's `README.md`.
5. Ensure the role is idempotent before merging.

## Environment Differences

| Concern | Staging | Production |
|---------|---------|------------|
| Host topology | Single host | Multiple dedicated hosts |
| Database | Co-located | Dedicated `database` group |
| Monitoring | Co-located | Dedicated `monitoring` group |
| Secrets management | Plain group_vars (local network) | Ansible Vault encrypted |
