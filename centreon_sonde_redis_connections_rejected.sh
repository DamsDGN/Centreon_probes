#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 20/04/2020
#
#		Monitored product: Redis
#       Called by Centreon to check Redis DB connections rejected
#
#########################################################################


####### SETUP #######
SERVER=$1         # REDIS SERVER (-h)
PORT=$2           # REDIS DB PORT (-p)
PASSWORD=$3       # REDIS DB PASSWORD (-a)
CONNECTION_NB=$4  # NUMBER OF REJECTED CONNECTIONS
REJECTED_CONNECTIONS=$(redis-cli --no-auth-warning -h $SERVER -p $PORT -a $PASSWORD info stats | grep -i "rejected_connections:" | sed 's/[^0-9]//g')  # Recovery of rejected connections number

# CENTREON THRESHOLDS AND ALERTS
# NORMAL
if [ "$REJECTED_CONNECTIONS" -eq 0 ]; then
 echo "OK - Aucune connexion rejetee"
 exit 0
fi

# WARNING
if [ "$REJECTED_CONNECTIONS" -le "$CONNECTION_NB" ]; then
 echo "CRITICAL - $REJECTED_CONNECTIONS connexion(s) rejetee(s) | connection=$REJECTED_CONNECTIONS"
 exit 1
fi

# CRITICAL
if [ "$REJECTED_CONNECTIONS" -gt "$CONNECTION_NB" ]; then
 echo "CRITICAL - $REJECTED_CONNECTIONS connexion(s) rejetee | connection=$REJECTED_CONNECTIONS"
 exit 2
fi
