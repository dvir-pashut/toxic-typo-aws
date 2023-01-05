#!/bin/bash

docker rm -f tox-app

docker pull 644435390668.dkr.ecr.eu-west-3.amazonaws.com/dvir-toxictypo:latest

docker run -d -p 8080:8080 --name tox-app 644435390668.dkr.ecr.eu-west-3.amazonaws.com/dvir-toxictypo:latest