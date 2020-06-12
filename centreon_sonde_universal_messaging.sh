#!/bin/bash

#########################################################################
#
#       Created by : Damien DAGORN
#       Tunned by  : Damien DAGORN
#       On         : 18/05/2020
#
#       Called by Centreon to check Universal Messaging status
#
#########################################################################


####### SETUP #######
SERVEUR=$1                                                                                                                                                                                                                                                                                           # Noeud du cluster ElasticSearch
PORT=$2                                                                                                                                                                                                                                                                                              # Port utilise par ElasticSearch
GTE=$3                                                                                                                                                                                                                                                                                               # Creneau utilise dans la DSL_QUERY2 en secondes (ex: 300)
LTE=$4                                                                                                                                                                                                                                                                                               # Creneau utilise dans la DSL_QUERY2 en secondes (ex: 60)
MINUTES=$(($GTE/60))                                                                                                                                                                                                                                                                                 # Variable utilisee pour la mise en forme de la reponse
NORMAL=$5                                                                                                                                                                                                                                                                                            # Nombre "normal" de documents
CRITICAL=$6                                                                                                                                                                                                                                                                                          # Nombre "insuffisant" de documents
HOSTNAME=$7                                                                                                                                                                                                                                                                                          # Nom du serveur concerné par la recherche
TAG=$8                                                                                                                                                                                                                                                                                               # Tag pour différencient UM_IS et UM_INT

INDEX="bb-supervision-$(date +%Y.%m.%d)"                                                                                                                                                                                                                                                             # Index ElasticSearch
DSL_QUERY1='{"query":{"bool":{"must":[{"match":{"tags.keyword":"'$TAG'"}},{"match":{"beat.name.keyword":"'$HOSTNAME'"}},{"match":{"Log":"ServerStatusLog"}}],"must_not":[],"should":[]}},"from":0,"size":1,"sort":[{"@timestamp":"desc"}],"aggs":{}}'                                                # Récupération du dernier enregistrement
DSL_QUERY2='{"query":{"bool":{"must":[{"match":{"tags.keyword":"'$TAG'"}},{"match":{"beat.name.keyword":"'$HOSTNAME'"}},{"match":{"Log":"ServerStatusLog"}},{"range":{"@timestamp":{"gte":"now/s-'$GTE's","lte":"now/s-'$LTE's"}}}]}},"from":0,"size":1},"sort":[{"@timestamp":"desc"}],"aggs":{}'   # Récupération d'un enregistrement
REQUEST1=$(curl -s -XPOST http://$SERVEUR:$PORT/$INDEX/_search -H "Content-Type: application/json" -d $DSL_QUERY1)                                                                                                                                                                                   # Execution de DSL_QUERY1
REQUEST2=$(curl -s -XPOST http://$SERVEUR:$PORT/$INDEX/_search -H "Content-Type: application/json" -d $DSL_QUERY2)                                                                                                                                                                                   # Execution de DSL_QUERY2

PUBLISHED1=$(echo $REQUEST1 | grep -Eo Published=[0-9]+ | sed 's/[^0-9]//g')                                                                                                                                                                                                                         # Published documents
PUBLISHED2=$(echo $REQUEST2 | grep -Eo Published=[0-9]+ | sed 's/[^0-9]//g')                                                                                                                                                                                                                         # Published documents
CONSUMED1=$(echo $REQUEST1 | grep -Eo Consumed=[0-9]+ | sed 's/[^0-9]//g')                                                                                                                                                                                                                           # Consummed documents
CONSUMED2=$(echo $REQUEST2 | grep -Eo Consumed=[0-9]+ | sed 's/[^0-9]//g')


PUBLISHED=$(($PUBLISHED1 - $PUBLISHED2))
CONSUMED=$(($CONSUMED1 - $CONSUMED2))


# CENTREON THRESHOLDS AND ALERTS
# NORMAL
if [ $PUBLISHED -gt $NORMAL ] && [ $CONSUMED -gt $NORMAL ]; then
 echo "OK - $PUBLISHED DOCUMENTS PUBLIES ET $CONSUMED DOCUMENTS CONSOMMES DANS LES $MINUTES DERNIERES MINUTES | published=$PUBLISHED | consumed=$CONSUMED"
 exit 0
fi

# WARNING
if [ $PUBLISHED -lt $NORMAL ] && [ $PUBLISHED -gt $CRITICAL ] || [ $CONSUMED -lt $NORMAL ] && [ $CONSUMED -gt $CRITICAL ]; then
 echo "WARNING - $PUBLISHED DOCUMENTS PUBLIES ET $CONSUMED DOCUMENTS CONSOMMES DANS LES $MINUTES DERNIERES MINUTES | published=$PUBLISHED | consumed=$CONSUMED"
 exit 1
fi

# CRITICAL
if [ $PUBLISHED -lt $CRITICAL ] || [ $CONSUMED -lt $CRITICAL ]; then
 echo "CRITICAL - $PUBLISHED DOCUMENTS PUBLIES ET $CONSUMED DOCUMENTS CONSOMMES DANS LES $MINUTES DERNIERES MINUTES | published=$PUBLISHED | consumed=$CONSUMED"
 exit 2
fi



