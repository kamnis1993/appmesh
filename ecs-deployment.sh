#!/bin/bash

REGION=ap-northeast-1
ACCOUNT_ID=381492111475
ACCESS_KEY=AKIAVRUVTVBZ5ZX2AMFX
SECRET_KEY=igmM8hV2S5kYJYlGXe6lIv5f/DkMdroiQJf3PpdH
COMMIT_HASH=default
ECS_SERVICE_ARN=arn:aws:ecs:ap-northeast-1:381492111475:cluster/example

# Define an array of task definitions
TASK_DEFINITIONS=("examplegw:1" "example2:1" "example1:1")

# Iterate through task definitions and update ECS service
for TASK_DEF in "${TASK_DEFINITIONS[@]}"; do
  aws ecs update-service \
    --region $REGION \
    --cluster example \
    --service $ECS_SERVICE_ARN \
    --task-definition $TASK_DEF

  # Tag ECS tasks with the commit hash
  aws ecs tag-resource \
    --region $REGION \
    --resource-arn $ECS_SERVICE_ARN \
    --tags Key=CommitHash,Value=$COMMIT_HASH
done

