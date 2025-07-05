#!/bin/bash
#cis-master.sh

total_fail=$(./kube-bench run master --check 1.1.1,1.1.1 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed MASTER while testing for 1.1.1,1.1.1"
                exit 1;
        else
                echo "CIS Benchmark Passed for MASTER - 1.1.1,1.1.1"
fi;
