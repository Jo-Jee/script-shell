#!/bin/bash

ip=$(echo $1 | sed 's/ip-//' | sed 's/.ap-northeast-2.compute.internal.*//' | sed 's/-/./g')

instance_id="$(aws ec2 describe-instances --filter Name=private-ip-address,Values=$ip --query 'Reservations[].Instances[].InstanceId' --output text)"

aws ssm start-session --target=$instance_id
