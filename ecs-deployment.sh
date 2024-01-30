#!/bin/bash

REGION=ap-northeast-1
ACCOUNT_ID=381492111475
ACCESS_KEY=AKIAVRUVTVBZ5ZX2AMFX
SECRET_KEY=igmM8hV2S5kYJYlGXe6lIv5f/DkMdroiQJf3PpdH
COMMIT_HASH=default
ECS_SERVICE_ARN=arn:aws:ecs:ap-northeast-1:381492111475:cluster/example

# Your ECS deployment commands here

# Example ECS Update Service Command
aws ecs update-service \
  --region $REGION \
  --cluster your-cluster-name \
  --service $ECS_SERVICE_ARN \
  --task-definition your-task-definition:latest

# Tag ECS tasks with the commit hash
#aws ecs tag-resource \
#  --region $REGION \
#  --resource-arn $ECS_SERVICE_ARN \
#  --tags Key=Name,Value=$COMMIT_HASH
