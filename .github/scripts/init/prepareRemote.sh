#!/bin/bash
ssh -o "StrictHostKeyChecking accept-new" $USER@$HOST

apt-get update

exit
