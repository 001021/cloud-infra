#!/bin/bash

# 확인할 IAM Role 목록
ROLE_NAMES=(
    "eks-ct01-test-je-01-cluster-20250227004651429600000002"
    "***REMOVED***eks-ct01-test-je-01-argocd-role-01"
    "***REMOVED***eks-ct01-test-je-01-aws-cloudwatch-metrics-role-01"
    "***REMOVED***eks-ct01-test-je-01-aws-lb-controller-role-01"
    "***REMOVED***eks-ct01-test-je-01-cloud9-role-01"
    "***REMOVED***eks-ct01-test-je-01-node-role"
)

echo "🔍 Checking IAM Role deletion status..."
for ROLE in "${ROLE_NAMES[@]}"; do
    if aws iam get-role --role-name "$ROLE" >/dev/null 2>&1; then
        echo "❌ $ROLE still exists!"
    else
        echo "✅ $ROLE is deleted!"
    fi
done

echo "🎉 IAM Role deletion check completed!"
