#!/bin/bash

# 확인할 IAM Role 목록
ROLE_NAMES=(
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
