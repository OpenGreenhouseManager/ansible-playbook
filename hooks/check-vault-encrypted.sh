#!/bin/bash

set -e

failed=0

for file in "$@"; do
  # Check if the file is Ansible Vault encrypted
  if ! grep -q '^$ANSIBLE_VAULT;' "$file"; then
    echo "[ERROR] $file is not encrypted with Ansible Vault"
    failed=1
  fi
done

exit $failed