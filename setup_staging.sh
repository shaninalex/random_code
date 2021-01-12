#!/bin/sh

APP_NAME=$1

# require to install git-all

# check if folder git-hooks exists if not 
mkdir /home/$USER/git-hooks
git init --bare /home/$USER/git-hooks/$APP_NAME.git

# SETUP GUNICORN

# SETUP nginx
