#!/bin/bash

#k8s-deployment.sh

# kubectl -n default get deployment devsecops-deployment > /dev/null

# if [[ $? -ne 0 ]]; then
#     echo "deployment devsecops-deployment doesn't exist"
#     kubectl -n default apply -f deployment.yaml
#     kubectl -n default apply -f service.yaml
# else
#     echo "deployment devsecops-deployment exist"
#     echo "image name - masudrana09/numeric-app:latest"
#     kubectl -n default set image deploy devsecops-deployment devsecops-container=masudrana09/numeric-app:latest --record=true
# fi

    kubectl -n default apply -f deployment.yaml
    kubectl -n default apply -f service.yaml