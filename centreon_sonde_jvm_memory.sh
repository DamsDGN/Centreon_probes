#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 18/03/2020
#
#				Monitored product: WebMethods Integration Server
#       Called by Centreon to check JVM memory status
#
#########################################################################


####### SETUP #######
SERVEUR=$1
USERNAME=$2
PASSWORD=$3
NORMAL=$4
WARNING1=$5
WARNING2=$6
CRITICAL=$7
SESSION_TIME=$8
COOKIE_FILE=/tmp/${SERVEUR}_SESSION_COOKIE

# GESTION DU COOKIE DE SESSION
CHECK_COOKIE=$(find $COOKIE_FILE -mmin -$SESSION_TIME | wc -l)
if [ "$CHECK_COOKIE" -eq "0" ]; then
	truncate -s0 ${COOKIE_FILE}
	CURL_RESULT=$(curl -s --cookie-jar ${COOKIE_FILE} --user ${USERNAME}:${PASSWORD} -GET "http://"${SERVEUR}":5555/invoke/wm.server.query/getResourceSettings" -H "Content-Type: application/json" | grep -Eo '"value":"[0-9]+ % \([0-9]+ KB\)","title":"Available Memory"')
fi

if [ "$CHECK_COOKIE" -gt "0" ]; then
	# EXECUTION DE LA REQUETE
	CURL_RESULT=$(curl -s --cookie ${COOKIE_FILE} --user ${USERNAME}:${PASSWORD} -GET "http://"${SERVEUR}":5555/invoke/wm.server.query/getResourceSettings" -H "Content-Type: application/json" | grep -Eo '"value":"[0-9]+ % \([0-9]+ KB\)","title":"Available Memory"')
fi

RESULT=${CURL_RESULT:9:3}

# NORMAL
if [ "$RESULT" -gt "$NORMAL" ]; then
 echo "OK - $RESULT % memoire disponible (JVM)"
 exit 0
fi

# WARNING
if [ "$RESULT" -gt "$WARNING1" ] && [ "$RESULT" -lt "$WARNING2" ]; then
 echo "WARNING - $RESULT % memoire disponible (JVM)"
 exit 1
fi

# CRITICAL
if [ "$RESULT" -lt "$CRITICAL" ]; then
 echo "CRITICAL - $RESULT % memoire disponible (JVM)"
 exit 2
fi
