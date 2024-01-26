#!/bin/bash

clear

echo " _____           _        _                 _           _____             _
|_   _|         | |      | |               | |         |  __ \\           | |
  | |  _ __  ___| |_ __ _| | ___   __ _  __| | ___ _ __| |  | | ___   ___| | _____ _ __
  | | | '_ \\/ __| __/ _\` | |/ _ \\ / _\` |/ _\` |/ _ \\ '__| |  | |/ _ \\ / __| |/ / _ \\ '__|
 _| |_| | | \\__ \\ || (_| | | (_) | (_| | (_| |  __/ |  | |__| | (_) | (__|   <  __/ |
|_____|_| |_|___/\\__\\__,_|_|\\___/ \\__,_|\\__,_|\\___|_|  |_____/ \\___/ \\___|_|\\_\\___|_|
                                                                                         "

# Variables
instaloader_directory="/opt/instaloader"
container_name="instaloader"

# Main Script
if docker ps -a | grep -q $container_name; then
    echo "Stopping and removing existing container: $container_name"
    docker container stop $container_name
    docker container rm $container_name
fi

if docker images -q $container_name; then
    echo "Removing existing image: $container_name"
    docker rmi $container_name
fi

echo "Building new image: $container_name"
docker build $instaloader_directory -t $container_name:latest
echo "Starting new container: $container_name"
docker-compose -f $instaloader_directory/docker-compose.yml up -d
if docker ps | grep -q $container_name; then
    echo "Container $container_name has started successfully."
else
    echo "Error: Container $container_name failed to start."
fi