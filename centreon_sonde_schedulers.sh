#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 18/03/2020
#
#				Monitored product: WebMethods Integration Server
#       Called by Centreon to check schedulers status
#
#########################################################################


####### SETUP #######
SERVEUR=$1
USERNAME=$2
PASSWORD=$3
SCHEDULER_ID=$4
SESSION_TIME=$5
COOKIE_FILE=/tmp/${SERVEUR}_SESSION_COOKIE

# GESTION DU COOKIE DE SESSION
CHECK_COOKIE=$(find $COOKIE_FILE -mmin -$SESSION_TIME | wc -l)
if [ "$CHECK_COOKIE" -eq "0" ]; then
	truncate -s0 ${COOKIE_FILE}
	CURL_RESULT=$(curl -s --cookie-jar ${COOKIE_FILE} --user ${USERNAME}:${PASSWORD} -GET "http://${SERVEUR}:5555/invoke/pub.scheduler/getTaskInfo?taskID=$SCHEDULER_ID" -H "Content-Type: application/json" | grep -Eo '"execState":"[0-9]"')
fi

if [ "$CHECK_COOKIE" -gt "0" ]; then
	# EXECUTION DE LA REQUETE
	CURL_RESULT=$(curl -s --cookie ${COOKIE_FILE} --user ${USERNAME}:${PASSWORD} -GET "http://${SERVEUR}:5555/invoke/pub.scheduler/getTaskInfo?taskID=$SCHEDULER_ID" -H "Content-Type: application/json" | grep -Eo '"execState":"[0-9]"')
fi

RESULT=${CURL_RESULT:13:1}


# NORMAL
if [ "$RESULT" = 0 ]; then
 echo "OK"
 exit 0
fi

# WARNING
if [ "$RESULT" = 1 ]; then
 echo "OK"
 exit 0
fi

# CRITICAL
if [ "$RESULT" = 2 ]; then
 echo "CRITICAL"
 exit 2
fi
