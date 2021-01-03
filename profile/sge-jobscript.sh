#!/bin/bash
# properties = {properties}

# exit on first error
set -o errexit
# Note: you have to source this 
# twice sometimes for the environments to come thru (sleep is to )
source ~/.bashrc
sleep 2

{exec_job}
