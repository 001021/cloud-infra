#!/bin/bash

# 삭제할 IAM Role 목록
ROLE_NAMES=(
    "eks-ct01-test-je-01-cluster-20250227004651429600000002"
    "kt-sc-ct01-eks-ct01-test-je-01-argocd-role-01"
    "kt-sc-ct01-eks-ct01-test-je-01-aws-cloudwatch-metrics-role-01"
    "kt-sc-ct01-eks-ct01-test-je-01-aws-lb-controller-role-01"
    "kt-sc-ct01-eks-ct01-test-je-01-cloud9-role-01"
    "kt-sc-ct01-eks-ct01-test-je-01-node-role"
)

for ROLE in "${ROLE_NAMES[@]}"; do
    echo "🛑 Deleting IAM Role: $ROLE"

    # 1. 인라인 정책 삭제
    POLICY_NAMES=$(aws iam list-role-policies --role-name "$ROLE" --query "PolicyNames" --output text)
    for POLICY in $POLICY_NAMES; do
        echo "🗑 Removing inline policy: $POLICY"
        aws iam delete-role-policy --role-name "$ROLE" --policy-name "$POLICY"
    done

    # 2. 관리형 정책 Detach
    ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE" --query "AttachedPolicies[].PolicyArn" --output text)
    for POLICY_ARN in $ATTACHED_POLICIES; do
        echo "🔗 Detaching managed policy: $POLICY_ARN"
        aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$POLICY_ARN"
    done

    # 3. 인스턴스 프로파일 확인 후 제거
    INSTANCE_PROFILES=$(aws iam list-instance-profiles-for-role --role-name "$ROLE" --query "InstanceProfiles[].InstanceProfileName" --output text)
    for PROFILE in $INSTANCE_PROFILES; do
        echo "🚫 Removing role from instance profile: $PROFILE"
        aws iam remove-role-from-instance-profile --instance-profile-name "$PROFILE" --role-name "$ROLE"
        aws iam delete-instance-profile --instance-profile-name "$PROFILE"
    done

    # 4. IAM Role 삭제
    echo "❌ Deleting IAM Role: $ROLE"
    aws iam delete-role --role-name "$ROLE"
    echo "✅ IAM Role $ROLE deleted successfully."
done

echo "🎉 All roles deleted successfully!"
