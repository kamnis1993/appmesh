#!/bin/bash
set -e

# Set your AWS region
AWS_REGION="ap-northeast-1"

# Set your AppMesh parameters
APPMESH_NAME="example"
ROUTE_NAME="example"
VIRTUAL_ROUTER_NAME="example"
VIRTUAL_NODE_CANARY="example1"  # Change to your first virtual node
VIRTUAL_NODE_PRIMARY="example2"  # Change to your second virtual node

# Set thresholds for canary deployment
ERROR_THRESHOLD=10  # Set a threshold for acceptable error rate in percentage

# Function for logging
log() {
  echo "$(date +"%Y-%m-%d %T"): $1"
}

# Deploy initial traffic to the canary version with 0% weight
log "Deploying initial traffic to the canary version with 0% weight"
aws appmesh update-route --region $AWS_REGION \
  --mesh-name $APPMESH_NAME \
  --route-name $ROUTE_NAME \
  --virtual-router-name $VIRTUAL_ROUTER_NAME \
  --spec '{"httpRoute": {"action": {"weightedTargets": [{"virtualNode": "'$VIRTUAL_NODE_CANARY'", "weight": 1}]}, "match": { "prefix": "/" }}}'

# Sleep for a duration to observe metrics (adjust as needed)
log "Sleeping for 5 minutes to observe metrics"
sleep 60  # Sleep for 5 minutes

# Check metrics (example: error rate)
log "Checking metrics (error rate)"
error_rate=$(aws cloudwatch get-metric-data --region $AWS_REGION \
  --start-time $(date -u +%Y-%m-%dT%H:%M:%SZ --date '-5 minutes') \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --metric-data-queries '[{
    "Id": "m1",
    "MetricStat": {
      "Metric": {
        "Dimensions": [
          {"Name": "Route", "Value": "'$ROUTE_NAME'"},
          {"Name": "Mesh", "Value": "'$APPMESH_NAME'"},
          {"Name": "VirtualRouter", "Value": "'$VIRTUAL_ROUTER_NAME'"}
        ],
        "MetricName": "4xxError",
        "Namespace": "AWS/AppMesh"
      },
      "Period": 300,
      "Stat": "Sum",
      "Unit": "Count"
    },
    "ReturnData": true
  }]' \
  --output json \
  --query 'MetricDataResults[0].Values[0]')

# Compare error rate with the threshold
if (( $(echo "$error_rate > $ERROR_THRESHOLD" | bc -l) )); then
  # Rollback due to a high error rate
  log "Rolling back the canary deployment due to a high error rate"
  aws appmesh update-route --region $AWS_REGION \
    --mesh-name $APPMESH_NAME \
    --route-name $ROUTE_NAME \
    --virtual-router-name $VIRTUAL_ROUTER_NAME \
    --spec '{"httpRoute": {"action": {"weightedTargets": [{"virtualNode": "'$VIRTUAL_NODE_CANARY'", "weight": 1}]}, "match": { "prefix": "/" }}}'

  # Notify on rollback (add your notification logic)
  log "Canary deployment rolled back due to a high error rate. Notifying..."
  echo "Canary deployment rolled back due to a high error rate" | mail -s "Canary Deployment Rollback" your-email@example.com
else
  # Gradually increase canary traffic to 100%
  for weight in $(seq 10 10 100); do
    log "Updating canary traffic weight to $weight%"
    aws appmesh update-route --region $AWS_REGION \
      --mesh-name $APPMESH_NAME \
      --route-name $ROUTE_NAME \
      --virtual-router-name $VIRTUAL_ROUTER_NAME \
      --spec '{"httpRoute": {"action": {"weightedTargets": [{"virtualNode": "'$VIRTUAL_NODE_CANARY'", "weight": '$weight'}]}, "match": { "prefix": "/" }}}'

    # Sleep for a duration to observe metrics (adjust as needed)
    log "Sleeping for 5 minutes to observe metrics"
    sleep 300  # Sleep for 5 minutes
  done

  # Finalize by setting canary traffic to 100%
  log "Setting canary traffic to 100%"
  aws appmesh update-route --region $AWS_REGION \
    --mesh-name $APPMESH_NAME \
    --route-name $ROUTE_NAME \
    --virtual-router-name $VIRTUAL_ROUTER_NAME \
    --spec '{"httpRoute": {"action": {"weightedTargets": [{"virtualNode": "'$VIRTUAL_NODE_CANARY'", "weight": 100}]}, "match": { "prefix": "/" }}}'

  # Notify on successful canary deployment (add your notification logic)
  log "Canary deployment completed successfully"
fi

