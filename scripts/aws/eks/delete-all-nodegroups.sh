#!/bin/bash
set -e  # 오류 발생 시 즉시 종료

# 변수 설정
REGION="ap-northeast-2"  # AWS 리전
EKS_CLUSTER_NAME="eks-ct01-test-je-02"  # 삭제할 클러스터 이름

echo "🔍 Fetching all node groups in cluster: $EKS_CLUSTER_NAME..."

# 클러스터 내 모든 노드 그룹 가져오기
NODEGROUPS=$(aws eks list-nodegroups --cluster-name "$EKS_CLUSTER_NAME" --region "$REGION" --query "nodegroups" --output text)

if [ -z "$NODEGROUPS" ]; then
  echo "✅ No node groups found in cluster '$EKS_CLUSTER_NAME'. Nothing to delete."
  exit 0
fi

echo "🛑 The following node groups will be deleted:"
echo "$NODEGROUPS"

# 사용자 확인 (자동 실행하려면 아래 줄을 주석 처리)
read -p "⚠️  Are you sure you want to delete these node groups? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "❌ Operation cancelled."
  exit 1
fi

# 노드 그룹 삭제
for NODEGROUP in $NODEGROUPS; do
  echo "🚀 Deleting node group: $NODEGROUP..."
  aws eks delete-nodegroup --cluster-name "$EKS_CLUSTER_NAME" --nodegroup-name "$NODEGROUP" --region "$REGION"

  echo "⏳ Waiting for node group '$NODEGROUP' deletion to complete..."
  aws eks wait nodegroup-deleted --cluster-name "$EKS_CLUSTER_NAME" --nodegroup-name "$NODEGROUP" --region "$REGION"

  echo "✅ Node group '$NODEGROUP' deleted successfully!"
done

echo "🎉 All node groups in cluster '$EKS_CLUSTER_NAME' have been deleted!"
