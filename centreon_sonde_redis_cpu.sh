#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 17/04/2020
#
#		Monitored product: Redis
#       Called by Centreon to check Redis host CPU usage
#
#########################################################################


####### SETUP #######
SERVER=$1       # REDIS SERVER (-h)
PORT=$2         # REDIS DB PORT (-p)
PASSWORD=$3     # REDIS DB PASSWORD (-a)
CPU=$4          # RAM USAGE
SYSTEM_MEMORY=$(redis-cli --no-auth-warning -h $SERVER -p $PORT -a $PASSWORD info | grep -i "total_system_memory:" | sed 's/[^0-9]//g') # Recovery of the RAM allocated to the DB
USED_MEMORY=$(redis-cli --no-auth-warning -h $SERVER -p $PORT -a $PASSWORD info | grep -i "used_memory:" | sed 's/[^0-9]//g')           # Recovery of the RAM consummed by the DB

# CALCULATE USED MEMORY PERCENTAGE
USED_PERCENTAGE=$(((($USED_MEMORY * 100))/$SYSTEM_MEMORY))

# CENTREON THRESHOLDS AND ALERTS
# NORMAL
if [ "$USED_PERCENTAGE" -le "$RAM" ]; then
 echo "OK - $USED_PERCENTAGE% de RAM utilisée | RAM=$USED_PERCENTAGE"
 exit 0
fi

# CRITICAL
if [ "$USED_PERCENTAGE" -gt "$RAM" ]; then
 echo "CRITICAL - $USED_PERCENTAGE% de RAM utilisée | RAM=$USED_PERCENTAGE"
 exit 2
fi
