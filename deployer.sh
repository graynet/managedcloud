#!/bin/bash
# Sets active interface MTU
#
# Website Shield DDOS Protection
# MTU Config
# by Namehero.com
#
# This script sets active interface MTU to 1424
# sh /usr/bin/herodeploy/deploy.sh
#
# Find optimial MTU
# ping REMOTE_HOSTNAME -c 10 -M do -s 1500
# where 1500 is mtu then start subtracting by 28

FILE=/usr/bin/herodeploy/version.txt
# Check if script has run before
if test -f "$FILE"; then
    VERSION=$(cat version.txt)
    timeago='30 days ago'
    dtSec=$(date --date "$VERSION" +'%s')
    taSec=$(date --date "$timeago" +'%s')
    [ $dtSec -lt $taSec ] && wget https://raw.githubusercontent.com/graynet/managedcloud/master/deployer.sh
fi
date '+%Y-%m-%d %H:%M:%S' > version.txt

ip addr show | awk '/inet.*brd/{print $NF; exit}' > interface.txt

for INTERFACE in $(cat interface.txt ) ; do sed -i -e '$aMTU=1424' /etc/sysconfig/network-scripts/ifcfg-${INTERFACE} ; ip link set ${INTERFACE} mtu 1424 ; done ;