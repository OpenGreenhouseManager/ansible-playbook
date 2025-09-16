ansible-galaxy collection install -r requirements.yml

ansible-playbook -i inventory/staging/hosts.yml playbooks/staging.yml --ask-pass --ask-become-pass --vault-password-file .vault_pass.txt

EDITOR='code --wait'

python3 -m venv ./venv

source ./venv/bin/activate