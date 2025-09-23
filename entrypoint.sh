#! /bin/bash

echo "Starting JAVA Based Microservice Deployment......."

cd /platform

echo "JAVA_HOME={JAVA_HOME}"

java -jar *.jar

echo "Stopping Micorservice......."