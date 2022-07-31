#!/bin/bash
# Runs on initial boot after cloud-ini scripts
#
# Hero Deployer Master
# NameHero Managed Cloud
# by Namehero.com
#
# This script sets interface MTU and opens DDOS protected ports
# sh /usr/bin/herodeploy/deploy.sh
#
# Find optimial MTU
# ping REMOTE_HOSTNAME -c 10 -M do -s 1500
# where 1500 is mtu then start subtracting by 28
#
#
#

# Enter optimial MTU for active interfaces and I'll set that bad boy.
SETMTU=1376

# Version file and general variables
FILE=/usr/bin/herodeploy/version.txt
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOGFILE=/usr/bin/herodeploy/deploylog.txt

# Start a log file if not one
if [[ ! -f $LOGFILE ]]
then
    touch deploylog.txt
    echo "$DATE: Log File Created" >> deploylog.txt
fi

# Set cron if script has not run before
if [[ ! -f $FILE ]]
then
    echo "$DATE: Version file not found.  Setting crontab." >> deploylog.txt
    # Dump existing crons
    crontab -l > cron
    echo "$DATE: Existing crons dumped." >> deploylog.txt
    # Add deploy script 1 time a day M-F
    echo "00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh" >> cron
    crontab cron
    echo "$DATE: Cronjob has been set 00 00 * * 1-5 /usr/bin/sh /usr/bin/herodeploy/deploy.sh" >> deploylog.txt
    rm cron
    echo "$DATE: Cron dump file removed." >> deploylog.txt
    echo "$DATE" > version.txt
    echo "$DATE: Version file has been created: $FILE" >> deploylog.txt
fi

# Check if script needs updated
# If the version file exists

echo "$DATE: Checking for updates..." >> deploylog.txt
if test -f "$FILE"; then
  echo "$DATE: Version file found: $FILE" >> deploylog.txt
    # Get current version
    VERSION=$(cat version.txt)
    echo "$DATE: Current version is $VERSION." >> deploylog.txt
    timeago='7 days ago'
    dtSec=$(date --date "$VERSION" +'%s')
    taSec=$(date --date "$timeago" +'%s')
    # If version is older than 7 days download the update script and update the version file.
    [ $dtSec -lt $taSec ] && wget https://raw.githubusercontent.com/graynet/managedcloud/master/deployer.sh && echo "$DATE" > version.txt
    echo "$DATE: Version has been updated." >> deploylog.txt
fi

# Print active interface
ip addr show | awk '/inet.*brd/{print $NF; exit}' > interface.txt
ACTIVELINK=$(cat interface.txt)
echo "$DATE: The current active interface is $ACTIVELINK" >> deploylog.txt

# Set MTU on active interface to 1376 immediately and persist after reboot
for INTERFACE in $(cat interface.txt) ; do
  # Set MTU in interface config file.
  sed -i -e '$aMTU=$SETMTU' /etc/sysconfig/network-scripts/ifcfg-${INTERFACE} ;
  echo "$DATE: /etc/sysconfig/network-scripts/ifcfg-$INTERFACE has been updated." >> deploylog.txt ;
  # Set the active link to correct MTU
  ip link set ${INTERFACE} mtu $SETMTU ;
  echo "$DATE: The active $INTERFACE has been set to $SETMTU mtu." >> deploylog.txt ;
done ;

# Open DDOS Protected Ports
DDOS=/usr/bin/herodeploy/path-whitelist.sh

# If DDOS file detected then run that puppy.
if test -f "$DDOS"; then
  echo "$DATE: $DDOS detected.  Running that puppy." >> deploylog.txt ;
    sh $DDOS
    rm $DDOS
fi

echo "$DATE: I have reached the end for today.  Goodbye all - drink more caffeine and work harder." >> deploylog.txt ;