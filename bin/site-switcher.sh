#!/opt/homebrew/bin/bash

declare -A SITES=(
[site1]="http://localhost:8000/"
[site2]="http://localhost:9000/"
)

export expected_response="Alive";
export current_site="site1";

# FUNCTIONS
stop_other_sites() {
    curr_site=$1;
    for site in "${!SITES[@]}"
    do
        if [ "`./run-site-kafkastream.sh ${site} status`" == *"RUNNING"* ]
        then
            if [ "${site}" != "${curr_site}" ]
            then
                echo "Stopping $site...";
                bash -c "./run-site-kafkastream.sh ${site} stop";
                wait;
            fi
        fi
    done   
}

switch_site() {
    curr_site=$1
    for site in "${!SITES[@]}"
    do
        check_url=`curl -s ${SITES[$site]} | grep $expected_response`;
        if [ "$check_url" == "$expected_response" ]
        then
            new_site=$site;
            break;
        fi
    done

    # Default to 
    if [ "${new_site}" == "" ]
    then
        new_site=$curr_site;
    fi

    echo "${new_site}";
}

# MAIN
echo "Initialising...";
echo "Checking running sites...";

for site in "${!SITES[@]}"
do
    echo "${site} KafkaStream: `./run-site-kafkastream.sh ${site} status`";
done

echo "Default to ${SITES[$current_site]} if it is alive, else use other site .."
# Stop other site kafkastream if running
echo "INFO: before test - current_site=${current_site}";
stop_other_sites $current_site;

check_url=`curl -s ${SITES[$current_site]} | grep $expected_response`;
if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site${SITES[$current_site]} is Alive";
	    bash -c "./run-site-kafkastream.sh $current_site start";
        wait;
    else
        echo "Site ${SITES[$current_site]} is Down, switching site";
        current_site="$(switch_site $current_site)";
        bash -c "./run-site-kafkastream.sh $current_site start";
        wait;
fi

echo "INFO: before loop - current_site=${current_site}";
echo "Start monitoring loop..."
while true
do
    echo "INFO: in loop - current_site=${current_site}";
    check_url=`curl -s ${SITES[$current_site]} | grep $expected_response`;
    if [ "$check_url" == "$expected_response" ]
    then 
        echo "Site ${SITES[$current_site]} is Alive";
    else
        echo "Site ${SITES[$current_site]} is Down, switching site";
        echo "Scan for next site which is Alive and switch"
        current_site="$(switch_site $current_site)";
        # Stop other site kafkastreams if running
        stop_other_sites;
        check_url=`curl -s ${SITES[$current_site]} | grep $expected_response`;
        if [ "$check_url" == "$expected_response" ]
        then 
            bash -c "./run-site-kafkastream.sh $current_site start";
            wait;
        fi
    fi
    sleep 2;
done


