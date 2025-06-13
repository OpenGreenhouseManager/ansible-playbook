#!/bin/bash

# Base directory
BASE_DIR="."

# Create main directory structure
mkdir -p $BASE_DIR/{inventories/staging/group_vars,inventories/production/group_vars,playbooks,roles}

# Create role directories
for role in rust-service postgres prometheus grafana loki; do
  mkdir -p $BASE_DIR/roles/$role/{defaults,tasks}
done

mkdir -p $BASE_DIR/roles/rust-service/{templates,handlers}
mkdir -p $BASE_DIR/roles/postgres/templates
mkdir -p $BASE_DIR/roles/prometheus/files
mkdir -p $BASE_DIR/roles/grafana/files
mkdir -p $BASE_DIR/roles/loki/files

# Inventory files
touch $BASE_DIR/inventories/staging/hosts.ini
touch $BASE_DIR/inventories/staging/group_vars/all.yml
touch $BASE_DIR/inventories/staging/group_vars/monitoring.yml
touch $BASE_DIR/inventories/production/hosts.ini
touch $BASE_DIR/inventories/production/group_vars/all.yml
touch $BASE_DIR/inventories/production/group_vars/monitoring.yml

# Playbooks
touch $BASE_DIR/playbooks/site.yml
touch $BASE_DIR/playbooks/staging.yml
touch $BASE_DIR/playbooks/production.yml

# Ansible config
touch $BASE_DIR/ansible.cfg

# Rust service role
touch $BASE_DIR/roles/rust-service/defaults/main.yml
touch $BASE_DIR/roles/rust-service/tasks/main.yml
touch $BASE_DIR/roles/rust-service/templates/service.j2
touch $BASE_DIR/roles/rust-service/handlers/main.yml

# Postgres role
touch $BASE_DIR/roles/postgres/defaults/main.yml
touch $BASE_DIR/roles/postgres/tasks/main.yml
touch $BASE_DIR/roles/postgres/templates/postgres.conf.j2

# Prometheus role
touch $BASE_DIR/roles/prometheus/defaults/main.yml
touch $BASE_DIR/roles/prometheus/tasks/main.yml

# Grafana role
touch $BASE_DIR/roles/grafana/defaults/main.yml
touch $BASE_DIR/roles/grafana/tasks/main.yml

# Loki role
touch $BASE_DIR/roles/loki/defaults/main.yml
touch $BASE_DIR/roles/loki/tasks/main.yml