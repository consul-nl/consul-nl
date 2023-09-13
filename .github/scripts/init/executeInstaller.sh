#!/bin/bash
# Run this 'locally' (on the machine created by Github Actions)

# Install ansible
sudo apt install ansible

# Checkout installer
git clone $INSTALLER_REPO ~/installer
cd ~/installer

# Create a hosts file
sed -e "s/remote-server-ip-address/$HOST/" -e "s/root/$ANSIBLE_USER/" hosts.example > hosts

# Configuration for Letsencrypt
cd ~/installer/group_vars
sed -i -e 's/#domain:\ your_domain.com/domain:\ $DOMAIN/g' -e 's/Madrid/Amsterdam/g' -e 's/#letsencrypt_email: "your_email@example.com"/letsencrypt_email: "$CONTACT_EMAIL"/g' ./all

# Run the ansible playbook
cd ~/installer
ansible-playbook -v consul.yml -i hosts
