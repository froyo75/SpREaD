#!/bin/bash

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi -f $(docker images -a -q)
#docker volume rm $(docker volume ls -q)
#docker network prune -f
