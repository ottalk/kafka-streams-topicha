#!/bin/bash

PID_FILE="./run-site1-kafkastream.pid"
JAVA_HOME=/Users/ottalk/.sdkman/candidates/java/current/
JVM_OPTIONS="-Xms512M -Xmx1G -XX:+UseParallelGC"
JAR_FILE="../lib/topicha-0.0.1-SNAPSHOT.jar"

SPRING_CONF_DIR="-Dapp.name=spring-kafka-streams-topicha-site1 -Dapp.env=local -Dspring.config.location=../config/application-site1.properties -Dlogging.config=../config/logback-spring.xml -Dlog.file.root=../logs"
SPRING_ACTIVE_PROFILE="-Dspring.profiles.active=dev"
SPRING_OPTIONS="$SPRING_CONF_DIR $SPRING_ACTIVE_PROFILE"
RUN_OUTPUT_FILE="run-site1-kafkastream.out"

case "$1" in
start)
  nohup $JAVA_HOME/bin/java $SPRING_OPTIONS $JVM_OPTIONS -jar $JAR_FILE > $RUN_OUTPUT_FILE 2>&1  &
  echo "$!" > $PID_FILE
  echo "$0 STARTED"
  ;;
status)
  if [ -f $PID_FILE ]
  then
    if ps -p `cat $PID_FILE` > /dev/null
    then
      echo "$0 RUNNING"
    else 
      echo "$0 STOPPED"
    fi
  else
    echo "$0 STOPPED"
  fi
  ;;
stop)
  if [ -f $PID_FILE ]
  then
    kill `cat $PID_FILE`
    echo "$0 STOPPED"
    rm $PID_FILE
    rm "./$RUN_OUTPUT_FILE"
  else
    echo "$0 - It seems the process isn't running."
  fi
  ;;
  *)
    echo "USAGE: $0 <start|status|stop>"
esac