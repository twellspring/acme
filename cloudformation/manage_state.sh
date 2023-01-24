#!/usr/bin/env bash

COMPANY=acme-company
CFM_COMMAND=$1  # create-stack, update-stack, delete-stack
ENVIRONMENT=$2

case $CFM_COMMAND in 
delete-stack)
    aws cloudformation $CFM_COMMAND \
        --stack-name acme-${ENV}-terraform-backend \
    ;;
create-stack|update-stack)
    aws cloudformation $CFM_COMMAND \
        --stack-name acme-${ENVIRONMENT}-terraform-backend \
        --template-body file://terraform-backend.yaml \
        --parameters ParameterKey=StateBucketName,ParameterValue=${ENVIRONMENT}-terraform-state-${COMPANY} \
            ParameterKey=LockTableName,ParameterValue=${ENVIRONMENT}-terraform-state-${COMPANY} \
        --tags Key=${COMPANY}:environment,Value=$ENVIRONMENT \
            Key=iron:department,Value=engineering \
            Key=purpose,Value=terraform-backend
    ;;
*)
    echo "Invalid command, valid are create-stack, update-stack, delete-stack"
    ;;
esac