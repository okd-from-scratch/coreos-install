# coreos-install
Shell scripts to install CoreOS over a running OS installation

## Requirement
A running VPS running Debian 10 or newer, where you cannot boot a custom ISO, and the only thing you have is SSH access

## System specs
* At least 5GB of RAM

## Configuration
* Delete or change the SSH keys that are in `install.sh`

## Operation
* `curl -L -o /root/install.sh https://raw.githubusercontent.com/okd-from-scratch/coreos-install/main/install.sh`
* `bash install.sh`
