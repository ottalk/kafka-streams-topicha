#!/bin/bash

url_site1=http://localhost:8000
url_site2=http://localhost:9000
expected_response="Alive"
current_site=$url_site1

echo "Initialising..."
echo "Checking running sites..."
echo "Site1 KafkaStream: `./run-site1-kafkastream.sh status`"
echo "Site2 KafkaStream: `./run-site2-kafkastream.sh status`" 

echo "Default to $current_site if it is alive, else use other site .."
check_url=`curl -s $current_site | grep $expected_response`;
if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site $current_site is Alive";
        bash -c ./run-site1-kafkastream.sh start
        # Stop other site kafkastream if it is running
        bash -c ./run-site2-kafkastream.sh stop
    else
        echo "Site $current_site is Down, switching site to $url_site2";
        current_site=$url_site2
        check_url=`curl -s $current_site | grep $expected_response`;
        if [ "$check_url" == "$expected_response" ]
        then
            bash -c ./run-site2-kafkastream.sh start
            # Stop other site kafkastream if it is running
            bash -c ./run-site1-kafkastream.sh stop
        else
            echo "ERROR: Both sites are down..exiting, please investigate!"
            exit 1;
        fi
fi

echo "Start monitoring loop..."
while true
do
    check_url=`curl -s $current_site | grep $expected_response`;
    if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site $current_site is Alive";
    else
        echo "Site $current_site is Down, switching site";
        if [ "$current_site" == "$url_site1" ]
        then
            current_site=$url_site2;
        else
            current_site=$url_site1;
        fi
    fi
    sleep 2;
done


