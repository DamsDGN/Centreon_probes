#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 20/04/2020
#
#		Monitored product: Redis
#       Called by Centreon to check Redis rss memory status
#
#########################################################################


####### SETUP #######
SERVER=$1       # REDIS SERVER (-h)
PORT=$2         # REDIS DB PORT (-p)
PASSWORD=$3     # REDIS DB PASSWORD (-a)
N_RAM=$4        # NORMAL RAM USAGE
L_RAM=$5        # LOW RAM USAGE
RSS_MEMORY=$(redis-cli --no-auth-warning -h $SERVER -p $PORT -a $PASSWORD info | grep -i "used_memory_rss:" | sed 's/[^0-9]//g')  # Recovery of the RAM allocated to the DB
USED_MEMORY=$(redis-cli --no-auth-warning -h $SERVER -p $PORT -a $PASSWORD info | grep -i "used_memory:" | sed 's/[^0-9]//g')     # Recovery of the RAM consummed by the DB

# CALCULATE USED MEMORY PERCENTAGE
USED_PERCENTAGE=$(((($USED_MEMORY * 100))/$RSS_MEMORY))

# CENTREON THRESHOLDS AND ALERTS
# NORMAL
if [ "$USED_PERCENTAGE" -le "$N_RAM" ]; then
 echo "OK - $USED_PERCENTAGE% de la RAM allouee est utilisee | RAM=$USED_PERCENTAGE"
 exit 0
fi

# CRITICAL
if [ "$USED_PERCENTAGE" -lt "$L_RAM" ]; then
 echo "CRITICAL - $USED_PERCENTAGE% de la RAM allouee est utilisee (verifier le service redis-server) | RAM=$USED_PERCENTAGE"
 exit 2
fi

# CRITICAL
if [ "$USED_PERCENTAGE" -gt "$N_RAM" ]; then
 echo "CRITICAL - $USED_PERCENTAGE% de la RAM allouee est utilisee (surallocation de memoire: verifier les connexions a la DB) | RAM=$USED_PERCENTAGE"
 exit 2
fi
