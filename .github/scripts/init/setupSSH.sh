#!/bin/bash

mkdir -p ~/.ssh/

echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
echo "$SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub

sudo chmod 600 ~/.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa.pub

