#!/bin/bash
ssh -o "StrictHostKeyChecking accept-new" $USER@$HOST

sudo apt-get update

exit
