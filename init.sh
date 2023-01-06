#!/bin/bash

ec2_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# remove from target group
aws elbv2 deregister-targets \
--target-group-arn arn:aws:elasticloadbalancing:eu-west-3:644435390668:targetgroup/dvirtg/8cdc359352c43e17 \
--targets Id="${ec2_id}"

# give time to the command to go through so no down time
sleep 10

docker rm -f tox-app
docker pull 644435390668.dkr.ecr.eu-west-3.amazonaws.com/dvir-toxictypo:latest
docker run -d -p 8080:8080 --name tox-app 644435390668.dkr.ecr.eu-west-3.amazonaws.com/dvir-toxictypo:latest

# give the app time to be functional 
sleep 10

# updtate the app name from /api/name
curl -X POST -F "name=${ec2_id}" "http://localhost:8080/api/name"


# add back to target group 
aws elbv2 register-targets \
--target-group-arn arn:aws:elasticloadbalancing:eu-west-3:644435390668:targetgroup/dvirtg/8cdc359352c43e17 \
--targets Id="${ec2_id}"

# give time to the command to go through so no down time
sleep 10
