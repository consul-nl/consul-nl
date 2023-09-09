#!/bin/bash

optOrArg=$1
argOrNone=$2

if [ "$optOrArg" = "-p" ]; then
  arg=$argOrNone
  production=true
else
  production=false
  arg=$optOrArg
fi

source .env.${arg}

# bin/tenant -a ${arg}

cd ./config
sed -e "s/xxx.xxx.xxx.xxx/$HOST/" -e "s/user: "deploy"/user: "$ANSIBLE_USER"/" deploy-secrets.yml.example > deploy-secrets.yml

echo "$REPO"

cap production deploy
