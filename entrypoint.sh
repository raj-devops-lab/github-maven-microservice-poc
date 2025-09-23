#!/bin/bash
set -e

echo "Starting JAVA Based Microservice Deployment......."

cd /platform

echo "JAVA_HOME=$JAVA_HOME"
echo "Java version:"
java -version

# Run the JAR (replace shell with Java for signal handling)
exec java -jar app.jar
