#!/bin/bash

# Define a pattern for files that should be encrypted
VAULT_FILE_PATTERN="(group_vars|host_vars)/.*\.ya?ml$"

# Flag to track violations
EXIT_CODE=0

# Loop through staged files matching the pattern
for file in $(git diff --cached --name-only | grep -E "$VAULT_FILE_PATTERN"); do
    # Check if the file starts with $ANSIBLE_VAULT
    if ! grep -q "\$ANSIBLE_VAULT;" "$file"; then
        echo "❌ File '$file' is not encrypted with Ansible Vault!"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -ne 0 ]; then
    echo "💡 Please encrypt the file(s) using:"
    echo "    ansible-vault encrypt <file>"
    echo ""
    exit 1
fi

exit 0