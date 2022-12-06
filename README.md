# utils-firefox-nosnap
Install Firefox from scratch and delete links to snap and apt packages

Two versions:
- Ansible, for multiple remote hosts
- Bash, for a single local host

Bash:
`./install-firefox.sh`

Ansible:
1) Specify the relevant hosts and variables in hosts file.
2) Run the playbook with the following command: `ansible-playbook playbooks/install-firefox.yaml -i hosts --ask-become-pass`
3) As some tasks require privilege elevation, you will be prompted for sudo credentials.
