#!/bin/bash
# Runs on initial boot after cloud-init scripts
####################################################
####################################################
####################################################
# The Deployer KCDC
# NodeVM Server Deployment And Provisioning
# by Ryan Gray CEO NameHero.com
#
# This script is The Deployer.
# The maker of all VMs.
####################################################
####################################################
####################################################
#
# sh /usr/bin/herodeploy/deploy.sh
# Cron should be set up at least 1 time per week

####################################################
# # Setup Network MTU
####################################################
# We need to first find optimal MTU:
# $ ping REMOTE_HOSTNAME -c 10 -M do -s 1500
# where 1500 is mtu then start subtracting by 28
#
####################################################
####################################################
# Enter optimal MTU for active interfaces and I'll set that bad boy.
# System will default to 1376 on cloud-init.

####################################################
#
####################################################
# # Run cPanel Configuration
####################################################
# We need to ensure cPanel is using the correct shared IP
# as well as proper hostname/dns/and other network configs.
# If this server doesn't use cPanel, I'll do other important
# tasks such as setup and config critical OS components.
#
# sh /usr/bin/herodeploy/cpanel.sh
# Note: will self-destruct following first run.
#
####################################################
## Apply Website Shield DDOS Protection
####################################################
# Ensure VM is completely protected by our "Always On"
# DDS protection powered by Website Shield.  Will only open
# ports that are needed.  Un-used services should NOT be opened.
#
# Source: 0.0.0.0/0 (all subnets)
# Destination: (this server)
# Protocol: tcp/udp
# Dest Port: 443
# Whitelist: true
# Comment: "$HOSTNAME - Auto Added $DATE"
#
# sh /usr/bin/herodeploy/path-whitelist.sh
# Note: will self-destruct following first run.
#
####################################################
## Resize/Grow Disk
####################################################
# We use LVM on all Managed Cloud VPS's.
# This is hard coded for the following commands
# parted --script /dev/sda resizepart 2 100%
# pvresize /dev/sda2
# lvresize --extents +100%FREE --resizefs /dev/almalinux/root
#
# sh /usr/bin/herodeploy/grow-disk.sh
# Note: will self-destruct following first run.
#
####################################################
## Configure cPanel
####################################################
# If VPS uses cPanel this script sets hostname/nameserver
# Updates /etc/wwwacct.conf (add hostname,IP,ns1/ns2)
# Sets /etc/sysconfig/network-scripts/ifcfg to persist on reboots
# Adds Google and Cloudflare DNS resolvers
#
# sh /usr/bin/herodeploy/cpanel.sh
# Note: will self-destruct following first run.
#
####################################################
## Install Softaculous
####################################################
# This script will install and license Softaculous.
# Downloads latest version and installs (will update if installed)
# Orders a license for the IP instantly
#
# sh /usr/bin/herodeploy/softaculous.sh
# Note: will self-destruct following first run.
#
####################################################
## Setup DNS
####################################################
# This script creates A records for name servers and hostname.
# vpsXXX.nodevm.com
# ns1.vpsXXX.nodevm.com
# ns2.vpsXXX.nodevm.com
#
# sh /usr/bin/herodeploy/dns.sh
# Note: will self-destruct following first run.
#
####################################################
## Setup Imunify360
####################################################
# This script licenses Imunify360 Security
#
#
#
#
# sh /usr/bin/herodeploy/cloudlinux.sh
# Note: will self-destruct following first run.
#
####################################################
## Setup LiteSpeed
####################################################
# This script installs/configures LiteSpeed
#
#
#
#
# bash /usr/bin/herodeploy/litespeed.sh
# Note: will self-destruct following first run.
# MUST use bash for this guy bc syntax
####################################################
## Send Alerts And Finish Up
####################################################
# Make KCDC Sys Ops aware of deployment results and address any errors.
# Review that DDOS protection was applied properly and distributed to BGP routers.
#
# sh /usr/bin/herodeploy/email-alert.sh
#
#From : "servers@namehero.com",
#To: "ryan@heroicmail.com",
#Subject: "Hero Deployer [ALERT]: $HOSTNAME $IP Deployed Successfully",
# HtmlBody: "$fulllog",
#MessageStream": "outbound"
#
####################################################
## Keep Eye On The Deployer
####################################################
# Within 7 days of initial deployment, The Deployer:
#
# sh /usr/bin/herodeploy/deployer.sh
# Will arrive via cron and will carry out further updates
# on reliability configurations (i.e. setup monitoring API).
#
####################################################
####################################################
####################################################### THE DEPLOY LOG ################################################
# This guy knows what's going on around these neck of the woods:
LOGFILE=/usr/bin/herodeploy/deploylog.txt
#
# Format:
# DATE : Task : Message
#
#######################################################################################################################
VERSION=/usr/bin/herodeploy/version.txt
DATE=$(date '+%Y-%m-%d %H:%M:%S')
####################################################### START LOGGING ################################################
# Start a log file if not one
if [ -f "$LOGFILE" ]; then
    echo "<em>$DATE:</em> $LOGFILE exists.  Previous run detected.<br>" >> $LOGFILE
else
    touch $LOGFILE
    echo "<em>$DATE:</em> $LOGFILE does not exist.  Starting one so we can get rolling!<br>" >> $LOGFILE
fi

####################################################### GET ACTIVE IP ################################################
echo "<em>$DATE:</em> Getting active hostname IP address.<br>" >> $LOGFILE
hostname -I | awk '{print $1}' > /usr/bin/herodeploy/ip.txt

# Variables for scripts
IP=$(cat /usr/bin/herodeploy/ip.txt)
HOSTNAME=$(hostname)
echo "<em>$DATE:</em> I'm here today with $HOSTNAME on $IP.<br>" >> $LOGFILE

####################################################### UPDATE CHECK ################################################
# Check if script needs updated
# If the version file exists

if [ -f "$VERSION" ]; then
    echo "<em>$DATE:</em> $VERSION exists.  Checking for updates...<br>" >> $LOGFILE
    # Get current version
    VERSION=$(cat /usr/bin/herodeploy/version.txt)
    echo "<em>$DATE:</em> Current version was deployed $VERSION.<br>" >> $LOGFILE
    timeago='7 days ago'
    dtSec=$(date --date "$VERSION" +'%s')
    taSec=$(date --date "$timeago" +'%s')
    echo "<em>$DATE:</em> Exact version is: $dtSec.<br>" >> $LOGFILE
    # If version is older than 7 days download the update script and update the version file.
    [ $dtSec -lt $taSec ] && wget https://raw.githubusercontent.com/graynet/managedcloud/master/deployer.sh && echo "$DATE" > /usr/bin/herodeploy/version.txt && echo "$DATE:Version has been updated to $dtSec." >> $LOGFILE
    # Run the update
    UPDATE=/usr/bin/herodeploy/deployer.sh
    if test -f "$UPDATE"; then
      echo "<em>$DATE:</em> <strong>UPDATE:</strong> $UPDATE detected.  Running that puppy.<br>" >> $LOGFILE
        sh $UPDATE
      echo "<em>$DATE:</em> <strong>UPDATE:</strong> $UPDATE has been run successfully.<br>" >> $LOGFILE
        rm $UPDATE
    echo "<em>$DATE:</em> <strong>UPDATE:</strong> $UPDATE file has been removed successfully.<br>" >> $LOGFILE
    else
      echo "<em>$DATE:</em> No updates found.  Current version is still $dtSec <br>" >> $LOGFILE
    fi
else
    echo "<em>$DATE:</em> Version file not found.  Creating one: $VERSION <br>" >> $LOGFILE
    touch /usr/bin/herodeploy/version.txt
    echo "<em>$DATE:</em> Version file created.  Setting initial crontab.<br>" >> $LOGFILE
    # Dump existing crons
    crontab -l > cron
    echo "<em>$DATE:</em> Existing crons dumped.<br>" >> $LOGFILE
    # Add deploy script 1 time a day M-F
    echo "00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh" >> cron
    crontab cron
    echo "<em>$DATE:</em> Cronjob has been set 00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh <br>" >> $LOGFILE
    rm cron
    echo "<em>$DATE:</em> Cron dump file removed.<br>" >> $LOGFILE
    echo "$DATE" > /usr/bin/herodeploy/version.txt
    echo "<em>$DATE:</em>: Current version has been set.<br>" >> $LOGFILE
fi

####################################################### SET MTU ################################################

# Set active interface MTU
MTU=/usr/bin/herodeploy/mtu.sh

# If MTU file detected then run that puppy.
if test -f "$MTU"; then
  echo "<em>$DATE:</em> <strong>SET MTU:</strong> $MTU detected.  Running that puppy.<br>" >> $LOGFILE
    sh $MTU
  echo "<em>$DATE:</em> <strong>SET MTU:</strong> $MTU has been run successfully.<br>" >> $LOGFILE
    rm $MTU
echo "<em>$DATE:</em> <strong>SET MTU:</strong> $MTU file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### WHITELIST DDOS ################################################
# Open DDOS Protected Ports
DDOS=/usr/bin/herodeploy/path-whitelist.sh

# If DDOS file detected then run that puppy.
if test -f "$DDOS"; then
  echo "<em>$DATE:</em> <strong>WHITELIST DDOS:</strong> $DDOS detected.  Running that puppy.<br>" >> $LOGFILE
    sh $DDOS
  echo "<em>$DATE:</em> <strong>WHITELIST DDOS:</strong> $DDOS has been run successfully.<br>" >> $LOGFILE
    rm $DDOS
echo "<em>$DATE:</em> <strong>WHITELIST DDOS:</strong> $DDOS file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### RESIZE DISK ################################################
# Resize disk to match correct storage
GROWDISK=/usr/bin/herodeploy/grow-disk.sh

# If grow disk file detected then run that puppy.
if test -f "$GROWDISK"; then
  echo "<em>$DATE:</em> <strong>DISK GROWER:</strong> $GROWDISK detected.  Running that puppy.<br>" >> $LOGFILE
    sh $GROWDISK
  echo "<em>$DATE:</em> <strong>DISK GROWER:</strong> $GROWDISK has been run successfully.<br>" >> $LOGFILE
    rm $GROWDISK
echo "<em>$DATE:</em> <strong>DISK GROWER:</strong> file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### CONFIG CPANEL ################################################
# Run cPanel's Provisioning Script
CPANEL=/usr/bin/herodeploy/cpanel.sh

# If cPanel config file detected then run that puppy.
if test -f "$CPANEL"; then
  echo "<em>$DATE:</em> <strong>CONFIG CPANEL:</strong> $CPANEL detected.  Running that puppy.<br>" >> $LOGFILE
    sh $CPANEL
  echo "<em>$DATE:</em> <strong>CONFIG CPANEL:</strong> $CPANEL has been run successfully.<br>" >> $LOGFILE
    rm $CPANEL
  echo "<em>$DATE:</em> <strong>CONFIG CPANEL:</strong> $CPANEL file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### INSTALL SOFTACULOUS ################################################
# License and Install Softaculous
SOFTACULOUS=/usr/bin/herodeploy/softaculous.sh

# If cPanel config file detected then run that puppy.
if test -f "$SOFTACULOUS"; then
  echo "<em>$DATE:</em> <strong>SOFTACULOUS:</strong> $SOFTACULOUS detected.  Running that puppy.<br>" >> $LOGFILE
    sh $SOFTACULOUS
  echo "<em>$DATE:</em> <strong>SOFTACULOUS:</strong> $SOFTACULOUS has been run successfully.<br>" >> $LOGFILE
    rm $SOFTACULOUS
  echo "<em>$DATE:</em> <strong>SOFTACULOUS:</strong> $SOFTACULOUS file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### SETUP DNS ################################################
# Open DDOS Protected Ports
  DNS=/usr/bin/herodeploy/dns.sh

  # If DNS file detected then run that puppy.
  if test -f "$DNS"; then
    echo "<em>$DATE:</em> <strong>DNS CONFIG:</strong> $DNS detected.  Running that puppy.<br>" >> $LOGFILE
      sh $DNS
    echo "<em>$DATE:</em> <strong>DNS CONFIG:</strong> $DNS has been run successfully.<br>" >> $LOGFILE
      rm $DNS
  echo "<em>$DATE:</em> <strong>DNS CONFIG:</strong> $DNS file has been removed successfully.<br>" >> $LOGFILE
  fi

####################################################### SETUP I360 ################################################
# Setup Imunify360
  CLOUDLINUX=/usr/bin/herodeploy/cloudlinux.sh

  # If CloudLinux.sh file detected then run that puppy.
  if test -f "$CLOUDLINUX"; then
    echo "<em>$DATE:</em> <strong>CLOUDLINUX:</strong> $CLOUDLINUX detected.  Running that puppy.<br>" >> $LOGFILE
      sh $CLOUDLINUX
    echo "<em>$DATE:</em> <strong>CLOUDLINUX:</strong> $CLOUDLINUX has been run successfully.<br>" >> $LOGFILE
      rm $CLOUDLINUX
  echo "<em>$DATE:</em> <strong>CLOUDLINUX:</strong> $CLOUDLINUX file has been removed successfully.<br>" >> $LOGFILE
  fi

####################################################### SETUP LITESPEED ################################################
# Setup LiteSpeed
  LITESPEED=/usr/bin/herodeploy/litespeed.sh

  # If Litespeed.sh file detected then run that puppy.
  if test -f "$LITESPEED"; then
    echo "<em>$DATE:</em> <strong>LITESPEED:</strong> $LITESPEED detected.  Running that puppy.<br>" >> $LOGFILE
      bash $LITESPEED
    echo "<em>$DATE:</em> <strong>LITESPEED:</strong> $LITESPEED has been run successfully.<br>" >> $LOGFILE
      rm $LITESPEED
  echo "<em>$DATE:</em> <strong>LITESPEED:</strong> $LITESPEED file has been removed successfully.<br>" >> $LOGFILE
  fi

####################################################### SEND ALERTS ################################################
# Send Email Alert
ALERT=/usr/bin/herodeploy/email-alert.sh

# If alert file ran, send it!
if test -f "$ALERT"; then
  echo "<em>$DATE:</em> <strong>SEND ALERTS:</strong> $ALERT detected.  Sending log file.<br>" >> $LOGFILE
    sh $ALERT
  echo "<em>$DATE:</em> <strong>SEND ALERTS:</strong> Email alert has been sent successfully.<br>" >> $LOGFILE
    rm $ALERT
  echo "<em>$DATE:</em> <strong>SEND ALERTS:</strong> $ALERT file has been removed successfully.<br>" >> $LOGFILE
fi

####################################################### CLOSE LOG FILE ################################################
echo "<em>$DATE:</em> <strong>CLOSE LOG FILE:</strong> I have reached the end for today.  Hero Deployer Master successfully ran.  Goodbye all - drink more caffeine and work harder.<br>" >> $LOGFILE
