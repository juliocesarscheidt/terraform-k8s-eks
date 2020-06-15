#!/bin/bash

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-"sa-east-1"}"
export CLUSTER_NAME="${CLUSTER_NAME:-"k8s-cluster"}"

AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?"[ERROR] Missing AWS Access Key"}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?"[ERROR] Missing AWS Secret Key"}"

echo "Deploying"

docker container run --name terraform --rm \
  -v "$PWD:/data" -it \
  --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --env AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  --env CLUSTER_NAME="$CLUSTER_NAME" \
  --entrypoint "" \
  hashicorp/terraform:0.12.24 sh -c \
  "cd /data && apk update && apk add --no-cache curl && \
  terraform init -backend=true && terraform validate && \
  terraform plan -out=./plan.tfplan 1> ./plan.txt 2>&1 && \
  terraform apply -auto-approve ./plan.tfplan 1> ./apply.txt && \
  terraform output kube_config_raw_config > ./${CLUSTER_NAME}-kubeconfig.yaml"

echo "Deployed successful"

exit 0