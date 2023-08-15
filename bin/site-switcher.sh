#!/bin/bash

declare -A SITES=(
 [site1]="http://localhost:8000/"
 [site2]="http://localhost:9000/"
)

expected_response="Alive"
current_site="site1"

# FUNCTIONS
stop_other_sites() {
    $curr_site=$1;
    for site in "${!SITES[@]}"
    do
        if [ "`./run-site1-kafkastream.sh ${site} status`" == *"RUNNING"* ]
        then
            if [ "${site}" != "${curr_site}" ]
            then
                echo "Stopping $site...";
                bash -c "./run-site1-kafkastream.sh ${site} stop";
            fi
        fi
    done   
}

switch_site() {
    $curr_site=$1;
    for site in "${!SITES[@]}"
    do
        if [ "${site}" != "${curr_site}" ]
        then
            check_url=`curl -s ${SITES[$site]} | grep $expected_response`;
            if [ "$check_url" == "$expected_response" ]
            then
                new_site=$site;
                bash -c "./run-site-kafkastream.sh $site start";
                break;
            fi
        fi
    done
    return ${new_site}
}

# MAIN
echo "Initialising..."
echo "Checking running sites..."
for site in "${!SITES[@]}"
do
 echo "${site} KafkaStream: `./run-site-kafkastream.sh ${site} status`"
done

echo "Default to ${SITES[$current_site]} if it is alive, else use other site .."
# Stop other site kafkastream if it is running
stop_other_sites $current_site;

check_url=`curl -s ${SITES[$current_site]} | grep $expected_response`;
if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site${SITES[$current_site]} is Alive";
        bash -c "./run-site-kafkastream.sh $current_site start";

    else
        echo "Site ${SITES[$current_site]} is Down, switching site";
        current_site="$(switch_site)";
        else
            echo "ERROR: Both sites are down..exiting, please investigate!"
            exit 1;
        fi
fi

echo "Start monitoring loop..."
while true
do
    check_url=`curl -s ${SITES[$current_site]} | grep $expected_response`;
    if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site ${SITES[$current_site]} is Alive";
    else
        echo "Site ${SITES[$current_site]} is Down, switching site";
        echo "Scan for next site which is Alive and switch"
        current_site="$(switch_site)";
        # Stop other site kafkastreams if running
        stop_other_sites $current_site;
    fi
    sleep 2;
done


