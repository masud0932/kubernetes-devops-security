#!/bin/bash

#k8s-deployment-rollout-status.sh

sleep 60s

if [[ $(kubectl -n default rollout status deploy devsecops-deployment --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment devsecops-deployment Rollout has Failed"
    kubectl -n default rollout undo deploy devsecops-deployment
    exit 1;
else
	echo "Deployment devsecops-deployment Rollout is Success"
fi

