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
# # 1) Setup Network MTU
####################################################
# We need to first find optimal MTU:
# $ ping REMOTE_HOSTNAME -c 10 -M do -s 1500
# where 1500 is mtu then start subtracting by 28
#
####################################################
####################################################
# Enter optimal MTU for active interfaces and I'll set that bad boy.
# System will default to 1376 on cloud-init.
MTU=/usr/bin/herodeploy/setmtu.txt
####################################################
#
####################################################
# # 2) Run cPanel Configuration
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
## 3) Apply Website Shield DDOS Protection
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
## 4) Send Alerts And Finish Up
####################################################
# Make KCDC Sys Ops aware of deployment results and address any errors.
# Review that DDOS protection was applied properly and distributed to BGP routers.
#
# sh /usr/bin/herodeploy/email-alert.sh
#
#From : "servers@namehero.com",
#To: "ryan@heroicmail.com",
#Subject: "Hero Deployer [ALERT]: Ports Have Been Opened On $IP",
# HtmlBody: "$fulllog",
#MessageStream": "outbound"
#
####################################################
## 5) Keep Eye On The Deployer
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
    echo "$DATE: $LOGFILE exists.  Previous run detected." >> $LOGFILE
else
    touch $LOGFILE
    echo "$DATE: $LOGFILE does not exist.  Starting one so we can get rolling!" >> $LOGFILE
fi

####################################################### GET ACTIVE IP ################################################
echo "$DATE: Getting active hostname IP address." >> $LOGFILE
hostname -I | awk '{print $1}' > /usr/bin/herodeploy/ip.txt

# Variables for scripts
IP=$(cat /usr/bin/herodeploy/ip.txt)
HOSTNAME=$(hostname)
echo "$DATE: I'm here today with $HOSTNAME on $IP." >> $LOGFILE

####################################################### UPDATE CHECK ################################################
# Check if script needs updated
# If the version file exists

if [ -f "$VERSION" ]; then
    echo "$DATE: $VERSION exists.  Checking for updates..." >> $LOGFILE
    # Get current version
    VERSION=$(cat /usr/bin/herodeploy/version.txt)
    echo "$DATE: Current version was deployed $VERSION." >> $LOGFILE
    timeago='7 days ago'
    dtSec=$(date --date "$VERSION" +'%s')
    taSec=$(date --date "$timeago" +'%s')
    echo "$DATE: Exact version is: $dtSec." >> $LOGFILE
    # If version is older than 7 days download the update script and update the version file.
    [ $dtSec -lt $taSec ] && wget https://raw.githubusercontent.com/graynet/managedcloud/master/deployer.sh && echo "$DATE" > /usr/bin/herodeploy/version.txt && echo "$DATE:Version has been updated to $dtSec." >> $LOGFILE
    echo "$DATE: No updates found.  Current version is still $dtSec" >> $LOGFILE
else
    echo "$DATE: Version file not found.  Creating one: $VERSION" >> $LOGFILE
    touch /usr/bin/herodeploy/version.txt
    echo "$DATE: Version file created.  Setting initial crontab." >> $LOGFILE
    # Dump existing crons
    crontab -l > cron
    echo "$DATE: Existing crons dumped." >> $LOGFILE
    # Add deploy script 1 time a day M-F
    echo "00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh" >> cron
    crontab cron
    echo "$DATE: Cronjob has been set 00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh" >> $LOGFILE
    rm cron
    echo "$DATE: Cron dump file removed." >> $LOGFILE
    echo "$DATE" > /usr/bin/herodeploy/version.txt
    echo "$DATE: Current version has been set." >> $LOGFILE
fi

####################################################### SET MTU ################################################
    echo "$DATE: SET MTU: Checking interface MTU setings..." >> $LOGFILE

# Print active interface
ip addr show | awk '/inet.*brd/{print $NF; exit}' > /usr/bin/herodeploy/interface.txt
ACTIVELINK=$(cat /usr/bin/herodeploy/interface.txt)
echo "$DATE: SET MTU: The current active interface is $ACTIVELINK" >> $LOGFILE

if [ -f "$MTU" ]; then
  SETMTU=$(cat /usr/bin/herodeploy/setmtu.txt)
  echo "$DATE: SET MTU: $MTU exists.  I will set active interfaces to $SETMTU." >> $LOGFILE
  # Set MTU on active interface to 1376 immediately and persist after reboot
  for INTERFACE in $(cat /usr/bin/herodeploy/interface.txt) ; do
      # Set the active link to correct MTU
      ip link set ${INTERFACE} mtu $SETMTU ;
      echo "$DATE: SET MTU: The active $INTERFACE has been set to $SETMTU mtu." >> $LOGFILE ;
  done ;
else
  echo "1376" > $MTU
  SETMTU=$(cat /usr/bin/herodeploy/setmtu.txt)
  echo "$DATE: SET MTU: $MTU not found.  Creating with default value $SETMTU." >> $LOGFILE
  for INTERFACE in $(cat /usr/bin/herodeploy/interface.txt) ; do
    # Set the active link to correct MTU
      ip link set ${INTERFACE} mtu $SETMTU ;
      echo "$DATE: SET MTU: The active $INTERFACE has been set to $SETMTU mtu." >> $LOGFILE ;
    # Set MTU in interface config file.
      sed -i -e '$aMTU=1376' /etc/sysconfig/network-scripts/ifcfg-${INTERFACE} ;
      echo "$DATE: SET MTU: /etc/sysconfig/network-scripts/ifcfg-$INTERFACE has been updated." >> $LOGFILE ;
    done ;
fi


####################################################### WHITELIST DDOS ################################################
# Open DDOS Protected Ports
DDOS=/usr/bin/herodeploy/path-whitelist.sh

# If DDOS file detected then run that puppy.
if test -f "$DDOS"; then
  echo "$DATE: WHITELIST DDOS: $DDOS detected.  Running that puppy." >> $LOGFILE
    sh $DDOS
  echo "$DATE: WHITELIST DDOS: $DDOS has been run successfully." >> $LOGFILE
    rm $DDOS
echo "$DATE: WHITELIST DDOS: $DDOS file has been removed successfully." >> $LOGFILE
fi

####################################################### CONFIG CPANEL ################################################
# Run cPanel's Provisioning Script
CPANEL=/usr/bin/herodeploy/cpanel.sh

# If cPanel config file detected then run that puppy.
if test -f "$CPANEL"; then
  echo "$DATE: CONFIG CPANEL: $CPANEL detected.  Running that puppy." >> $LOGFILE
    sh $CPANEL
  echo "$DATE: CONFIG CPANEL: $CPANEL has been run successfully." >> $LOGFILE
    rm $CPANEL
  echo "$DATE: CONFIG CPANEL: $CPANEL file has been removed successfully." >> $LOGFILE
  echo "$DATE: CONFIG CPANEL: Running cPanel update /scripts/upcp..." >> $LOGFILE
    /usr/local/cpanel/scripts/upcp
fi

####################################################### SEND ALERTS ################################################
# Send Email Alert
ALERT=/usr/bin/herodeploy/email-alert.sh

# If alert file ran, send it!
if test -f "$ALERT"; then
  echo "$DATE: SEND ALERTS: $ALERT detected.  Sending log file." >> $LOGFILE
    sh $ALERT
  echo "$DATE: SEND ALERTS: Email alert has been sent successfully." >> $LOGFILE
    rm $ALERT
  echo "$DATE: SEND ALERTS: $ALERT file has been removed successfully." >> $LOGFILE
fi

####################################################### CLOSE LOG FILE ################################################
echo "$DATE: CLOSE LOG FILE: I have reached the end for today.  Hero Deployer Master successfully ran.  Goodbye all - drink more caffeine and work harder." >> $LOGFILE
