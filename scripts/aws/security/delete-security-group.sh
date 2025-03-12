#!/bin/bash

REGION="ap-northeast-2"
SG_NAME=""

# Security Group ID 조회
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --region $REGION --query "SecurityGroups[*].GroupId" --output text)

if [[ -z "$SG_ID" ]]; then
    echo "❌ Security Group $SG_NAME not found in region $REGION"
    exit 1
fi

echo "🛑 Deleting Security Group: $SG_ID ($SG_NAME)"
aws ec2 delete-security-group --group-id "$SG_ID" --region $REGION

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully deleted Security Group: $SG_ID"
else
    echo "❌ Failed to delete Security Group. It may be in use."
fi
