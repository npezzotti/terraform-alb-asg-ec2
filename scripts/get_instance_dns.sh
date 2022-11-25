#!/bin/bash

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --output text --query "AutoScalingGroups[?name == $(terraform output asg_name)].Instances[].InstanceId")
PUBLIC_DNS_NAMES=$(aws ec2 describe-instances --instance-ids $INSTANCE_IDS --query "Reservations[].Instances[].PublicDnsName" --output text)

echo -n "ASG Instances public DNS names:"
for n in $PUBLIC_DNS_NAMES; do
    echo -n " $n"
done
