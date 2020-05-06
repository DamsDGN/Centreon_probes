#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 05/05/2020
#
#				Monitored product: WebMethods API Gateway
#       Called by Centreon to check API Gateway EventDataStore status
#
#########################################################################


####### SETUP #######
SERVER=$1      # ElasticSearch 
PORT=$2         # ElasticSearch port


CHECK_HEALTH=$(curl -s -GET http://$SERVER:$PORT/_cluster/health | grep -Eo '"status":"[a-z]+"')
HEALTH=$(echo $CHECK_HEALTH | grep -ow 'yellow\|red\|green')


# CENTREON THRESHOLDS AND ALERTS
# NORMAL
if [ "$HEALTH" == "green" ]; then
 echo "OK - STATUS DE EVENTDATASTORE (ElasticSearch): ${HEALTH^^}"
 exit 0
fi

# NORMAL
if [ "$HEALTH" == "yellow" ]; then
 echo "OK - STATUS DE EVENTDATASTORE (ElasticSearch): ${HEALTH^^}"
 exit 0
fi

# CRITICAL
if [ "$HEALTH" == "red" ]; then
 echo "CRITICAL - STATUS DE EVENTDATASTORE (ElasticSearch): ${HEALTH^^}"
 exit 2
fi
