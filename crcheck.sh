#!/bin/bash

# crcheck.sh
#
# This script will use RANCID login scripts to log into the routers
# and run a series of commands as a way of creating a snapshot and 
# dump the output to prefixed and timestamped per-router log files
#
# Copyright (c) 2018 Mariano Julia Quevedo <mjuliaq@guaca.net>
# v1.0 20181018 - First issue
# v1.1 20181019 - Added for function and forked excution
# v1.3 20181105 - Release
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

if [ -z $1 ]; then
        echo "Usage: $0 LOGFILE_PREFIX"
		echo ""
		echo "Eg. $0 mywork-checks"
        exit 1
fi

# common prefix to each log file
prefix=$1
# runtime timestamp
date=`date +%Y%m%d-%H%M`
# location of the rancid login script
clogin_bin="/usr/local/rancid/bin/clogin"

# Arrays of routers
c7200=(core-7206-1 core-7206-2)
c3500=(c3501 c3502)
nx7k=(nexus1 nexus2 core-nexus)

# Arrays of commands
c7200_commands="show clock;terminal length 0;show users;show version;show ntp associations;show ntp status;show logging;show diag;show environment all;show processes cpu sorted;show processes cpu history;show memory statistics;show memory summary;show memory free;show file systems;dir all-filesystems;show ip interface brief;show interfaces descriptions;show interfaces descriptions | exclude down;show interfaces descriptions | include down;show interfaces;show interfaces stats;show vlans;show ip protocols summary;show ip protocols;show ip route summary;show ip route;show ip ospf;show ip ospf interface;show ip ospf interface brief;show ip ospf neighbor;show ip ospf neighbor detail;show clns route;show clns neighbor;show arp;show standby brief;show standby;show spanning-tree;show cdp neighbors;show running-config;show running-config linenum full;"
c3500_commands="show clock;terminal length 0;show users;show version;show ntp associations ;show ntp status;show logging;show etherchannel detail;show inventory;show env all;show processes cpu sorted;show processes cpu history;show memory statistics;show memory summary;show memory free;show file systems;dir all-filesystems;show ip interface brief;show interfaces descriptions;show interfaces descriptions | exclude down;show interfaces descriptions | include down;show interfaces;show interfaces stats;show interfaces transceiver detail;show vlan internal usage;show vlan;show mac address-table;show mac address-table count;show ip protocols summary;show ip protocols;show ip route summary;show ip route;show ip ospf;show ip ospf interface;show ip ospf interface brief;show ip ospf neighbor;show ip ospf neighbor detail;show ip bgp;show ip bgp summary;show ip bgp neighbors;show arp;show standby brief;show standby;show spanning-tree bridge;show spanning-tree summary;show spanning-tree detail;show cdp neighbors;show running-config;show running-config full;"
nx7k_commands="show clock;terminal length 0;show users;show version;show logging last 2000;show port-channel database;show port-channel summary;show inventory;show environment;show processes cpu sort;show processes cpu history;show system exception-info;show system reset-reason;show system resources;show system uptime;show vdc detail;show ip interface brief vrf all;show interface descriptions;show interface status | include connected;show interface status | exclude connected;show interface;show interface transceiver details;show vlan internal usage;show vlan;show mac address-table;show mac address-table count;show ip route summary vrf all;show ip route vrf all;show ip ospf vrf all;show ip ospf interface vrf all;show ip ospf interface brief vrf all;show ip ospf neighbors vrf all;show ip ospf neighbors detail vrf all;show ip bgp vrf all;show ip bgp summary vrf all;show ip bgp neighbors vrf all;show ip arp vrf all;show hsrp brief all;show hsrp all;show spanning-tree bridge;show spanning-tree summary;show spanning-tree detail;show cdp neighbors;show running-config;show running-config all;"

# Main for function
main () {
    echo "Connecting to ${1}"
    eval "$3 -c\"$2\" $1 >> ${prefix}_${1}_${date}.log"
	if [ $? != 0 ]; then
		echo -e "\033[1;31mError while processing $1\033[0m"
	else 
		echo -e "\033[1;32m$1 DONE\033[0m"
	fi
}

# Run commands on each router
# Paralelise by forking shells "&"
# Remove ampersand to serialise
for router in ${c3500[@]}; do main "$router" "$c3500_commands" "$clogin_bin" & done
for router in ${c7200[@]}; do main "$router" "$c7200_commands" "$clogin_bin" & done
for router in ${nx7k[@]}; do main "$router" "$nx7k_commands" "$clogin_bin" & done

sleep 2

printf "\nDone. Please wait for child processes to report back\n\n"

exit 0