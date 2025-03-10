#!/bin/bash

# .env 파일 로드
if [ -f .env ]; then
    source .env
else
    echo "❌ .env 파일을 찾을 수 없습니다. .env.example을 참고하여 생성하세요."
    exit 1
fi

# AWS Service Catalog 제품 프로비저닝
aws servicecatalog provision-product \
  --product-name dev-eks-product \
  --provisioning-artifact-name v9.02 \
  --provisioned-product-name eks-ct01-${ENV_NAME}-${SERVICE_NAME}-${SEQUENCE_NUMBER} \
  --region $AWS_REGION \
  --provisioning-parameters \
      "Key=account_id,Value=$ACCOUNT_ID" \
      "Key=app_subnet_a,Value=$APP_SUBNET_A" \
      "Key=app_subnet_c,Value=$APP_SUBNET_C" \
      "Key=ccoe_admin_role_name,Value=$CCOE_ADMIN_ROLE" \
      "Key=common_nodegroup_instance_type,Value=$COMMON_NODEGROUP_INSTANCE_TYPE" \
      "Key=dev_team_role_name,Value=$DEV_TEAM_ROLE" \
      "Key=eks_version,Value=$EKS_VERSION" \
      "Key=elb_subnet_a,Value=$ELB_SUBNET_A" \
      "Key=elb_subnet_c,Value=$ELB_SUBNET_C" \
      "Key=env_name,Value=$ENV_NAME" \
      "Key=needs_for_argocd,Value=$NEEDS_FOR_ARGOCD" \
      "Key=node_desired_size,Value=$NODE_DESIRED_SIZE" \
      "Key=node_max_size,Value=$NODE_MAX_SIZE" \
      "Key=node_min_size,Value=$NODE_MIN_SIZE" \
      "Key=pod_subnet_a,Value=$POD_SUBNET_A" \
      "Key=pod_subnet_c,Value=$POD_SUBNET_C" \
      "Key=region,Value=$AWS_REGION" \
      "Key=service_name,Value=$SERVICE_NAME" \
      "Key=sequence_number,Value=$SEQUENCE_NUMBER" \
      "Key=user_ami_id,Value=$USER_AMI_ID" \
      "Key=vpc_id,Value=$VPC_ID"