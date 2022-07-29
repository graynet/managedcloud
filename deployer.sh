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
VERSION=$(date '+%Y-%m-%d %H:%M:%S')

# Check Version
timeago='30 days ago'
dtSec=$(date --date "$VERSION" +'%s')
taSec=$(date --date "$timeago" +'%s')
[ $dtSec -lt $taSec ] && echo do something

ip addr show | awk '/inet.*brd/{print $NF; exit}' > interface.txt

for INTERFACE in $(cat interface.txt ) ; do sed -i -e '$aMTU=1424' /etc/sysconfig/network-scripts/ifcfg-${INTERFACE} ; ip link set ${INTERFACE} mtu 1424 ; done ;

