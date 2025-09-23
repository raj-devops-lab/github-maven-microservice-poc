#!/bin/bash
set -e

echo "==============================================="
echo " Starting JAVA Based Microservice Deployment..."
echo "==============================================="

cd /platform

echo "JAVA_HOME=${JAVA_HOME}"
echo "Running JAR: app.jar"

exec java -jar app.jar
