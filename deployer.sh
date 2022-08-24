#!/bin/bash
# Checks Managed Cloud VMs for sanity and updates them for protection.
#
# The Deployer KCDC
# NodeVM Server Deployment And Provisioning
# by Ryan Gray CEO NameHero.com
#
# This script checks VPS with NameHero
# for sanity.  Auto downloads from Git.
#
# My name is Ryan Gray
# I am a hacker CEO
# I love speed and reliability.
# But I love your trust.
# So I am here to keep you safe.  Now drink more caffeine and work harder.
#

# Define some variables
DATE=$(date '+%Y-%m-%d %H:%M:%S')
IP=$(cat /usr/bin/herodeploy/ip.txt)
HOSTNAME=$(hostname)

echo "<em>$DATE:</em> <strong>DEPLOYER:</strong> The Hero Deployer Updater has been completed.<br>" >> deploylog.txt ;