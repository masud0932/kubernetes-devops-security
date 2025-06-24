#!/bin/bash

# Validate deployment name
if [[ -z "${deploymentName}" ]]; then
  echo "Error: deploymentName variable is not set"
  exit 1
fi

echo "Waiting for deployment rollout: ${deploymentName}"
sleep 10s  # Optional buffer

if [[ $(kubectl -n default rollout status deploy "${deploymentName}" --timeout=120s) != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy "${deploymentName}"
    exit 1
else
    echo "Deployment ${deploymentName} Rollout is Success"
fi

