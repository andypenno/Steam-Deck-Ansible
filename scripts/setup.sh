#!/bin/bash

#
# Setup script to prepare the Steam Deck for the execution of the ansible scripts
#

# Default variables
INSTALL=false
INSTALL_DIR=$HOME/.config/Steam-Deck-Ansible

# Argument Parsing
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      printf -- "usage: $0 [-i] [--install] [-d] [--dir INSTALLATION_DIRECTORY]\n\n"
      printf -- "arguments: \n"
      printf -- "-i, --install   -   Trigger the ansible scripts, defaults to: false\n"
      printf -- "-d, --dir       -   Installation directory, defaults to: $HOME/.config/Steam-Deck-Ansible\n"
      exit 0
      ;;
    -i|--install)
      INSTALL=true
      shift # past argument
      ;;
    -d|--dir)
      INSTALL_DIR=`readlink -f $2`
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      printf -- "Unknown option $1\n"
      exit 1
      ;;
  esac
done

# Add local binaries to PATH
export PATH=$PATH:$HOME/.local/bin

# Install dependencies
python3 -m ensurepip
pip3 install ansible-core

# Clone the scripts repository
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR
git clone -o $INSTALL_DIR https://github.com/andypenno/Steam-Deck-Ansible.git

# Install ansible requirements
ansible-galaxy install -r requirements.yml

# Notify the user, and trigger installation if passed as an argument
printf -- "Setup completed.\nThe default installation configuration is located in: '$INSTALL_DIR/inventories/local'.\n"
if [ "$INSTALL" = true ]
then
  # Trigger the installation
  printf -- "Triggering the installation.\n"
  ansible-playbook playbooks/main.yml
else
  # Notify the user to trigger the installation
  printf -- "To trigger installation, please run: 'cd $INSTALL_DIR && ansible-playbook playbooks/main.yml'\n"
fi
