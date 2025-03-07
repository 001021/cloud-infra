#!/bin/bash

# 변수 설정
REGION="ap-northeast-2"
EKS_CLUSTER_NAME="eks-ct01-test-je-02"  # 클러스터 이름
LAUNCH_TEMPLATE_NAME="eksnode-ct01-test-je-eks1.31-gpu-20250307110028"  # GPU 시작 템플릿
SUBNET_IDS="***REMOVED***"  # 사용할 서브넷
NODE_ROLE_ARN="arn:aws:iam::***REMOVED***:role/***REMOVED***eks-ct01-test-je-02-node-role"  # 노드 롤

# GPU 노드 그룹 설정 (노드 그룹 이름 | 인스턴스 유형 | 스토리지 크기)
declare -A GPU_NODE_GROUPS=(
  ["8-32-2"]="g4dn.xlarge|50GB"
)

# 버전 매핑
declare -A STORAGE_VERSION_MAP=(
  ["50GB"]="1"
  ["100GB"]="2"
  ["200GB"]="3"
)

# GPU 노드 그룹 생성
for NODE_GROUP in "${!GPU_NODE_GROUPS[@]}"; do
  INSTANCE_TYPE="$(echo ${GPU_NODE_GROUPS[$NODE_GROUP]} | cut -d'|' -f1)"
  STORAGE_SIZE="$(echo ${GPU_NODE_GROUPS[$NODE_GROUP]} | cut -d'|' -f2)"
  VERSION="${STORAGE_VERSION_MAP[$STORAGE_SIZE]}"

  echo "🚀 Creating GPU EKS Managed Node Group: $NODE_GROUP (Instance Type: $INSTANCE_TYPE, Storage: $STORAGE_SIZE, Version: $VERSION)..."
  
  aws eks create-nodegroup \
    --region "$REGION" \
    --cluster-name "$EKS_CLUSTER_NAME" \
    --nodegroup-name "$NODE_GROUP" \
    --capacity-type ON_DEMAND \
    --scaling-config minSize=0,maxSize=1,desiredSize=1 \
    --launch-template name="$LAUNCH_TEMPLATE_NAME",version="$VERSION" \
    --subnets $SUBNET_IDS \
    --instance-types "$INSTANCE_TYPE" \
    --node-role "$NODE_ROLE_ARN"

  if [ $? -eq 0 ]; then
    echo "✅ GPU Node Group '$NODE_GROUP' created successfully!"
  else
    echo "❌ Error creating GPU Node Group '$NODE_GROUP'"
    exit 1
  fi
done