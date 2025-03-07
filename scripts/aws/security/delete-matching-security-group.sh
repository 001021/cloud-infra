#!/bin/bash
set -e  # 오류 발생 시 즉시 종료

# AWS 리전 설정
REGION="ap-northeast-2"
SG_PREFIX="kt-sc-ct01-test-je-eks-cluster-secgrp-01"

echo "🔍 Searching for security groups with prefix '$SG_PREFIX'..."

# 특정 패턴을 포함하는 보안 그룹 ID 조회
SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups \
    --region "$REGION" \
    --query "SecurityGroups[?starts_with(GroupName, '$SG_PREFIX')].GroupId" \
    --output text)

if [ -z "$SECURITY_GROUP_IDS" ]; then
    echo "✅ No security groups found with prefix '$SG_PREFIX'. Nothing to delete."
    exit 0
fi

echo "🛑 The following security groups will be deleted:"
echo "$SECURITY_GROUP_IDS"

# 사용자 확인 (자동 실행하려면 아래 줄을 주석 처리)
read -p "⚠️  Are you sure you want to delete these security groups? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

# 보안 그룹 삭제
for SG_ID in $SECURITY_GROUP_IDS; do
    echo "🚀 Deleting security group: $SG_ID..."
    if aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION"; then
        echo "✅ Security group '$SG_ID' deleted successfully!"
    else
        echo "❌ Failed to delete security group '$SG_ID'. It may be in use by another resource."
    fi
done

echo "🎉 All matching security groups have been processed!"
