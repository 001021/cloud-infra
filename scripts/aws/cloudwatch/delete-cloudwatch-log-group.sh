#!/bin/bash

set -e  # 오류 발생 시 즉시 종료

# AWS 리전 설정
REGION="ap-northeast-2"
LOG_GROUP_PREFIX="/aws/eks/eks-ct01-test-je-01/cluster"

echo "🔍 Searching for CloudWatch log groups matching prefix '$LOG_GROUP_PREFIX'..."

# 특정 패턴을 포함하는 CloudWatch 로그 그룹 조회
LOG_GROUPS=$(aws logs describe-log-groups \
    --region "$REGION" \
    --query "logGroups[?starts_with(logGroupName, '$LOG_GROUP_PREFIX')].logGroupName" \
    --output text)

if [ -z "$LOG_GROUPS" ]; then
    echo "✅ No matching CloudWatch log groups found. Nothing to delete."
    exit 0
fi

echo "🛑 The following CloudWatch log groups will be deleted:"
echo "$LOG_GROUPS"

# 사용자 확인 (자동 실행하려면 아래 줄을 주석 처리)
read -p "⚠️  Are you sure you want to delete these log groups? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

# CloudWatch Log Group 삭제
for LOG_GROUP in $LOG_GROUPS; do
    echo "🚀 Deleting CloudWatch Log Group: $LOG_GROUP..."
    if aws logs delete-log-group --log-group-name "$LOG_GROUP" --region "$REGION"; then
        echo "✅ Log group '$LOG_GROUP' deleted successfully!"
    else
        echo "❌ Failed to delete log group '$LOG_GROUP'. It may be in use by another resource."
    fi
done

echo "🎉 All matching CloudWatch log groups have been processed!"
