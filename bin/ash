#!/bin/bash

instance_id=$1

if ! [[ $instance_id =~ ^i-[0-9a-z]* ]]
then
  ip=$(echo $1 | sed 's/ip-//' | sed 's/.ap-northeast-2.compute.internal.*//' | sed 's/-/./g')
  instance_id="$(aws ec2 describe-instances --filter Name=private-ip-address,Values=$ip --query 'Reservations[].Instances[].InstanceId' --output text)"
fi

aws ssm start-session --target=$instance_id
