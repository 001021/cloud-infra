#!/bin/bash

# 삭제할 Instance Profile 이름 패턴
PROFILE_PREFIX="kt-sc-ct01-eks-ct01-test-je-"
PROFILE_SUFFIX="-cloud9-dev-profile-"

echo "🔍 Searching and deleting instance profiles..."

for i in $(seq -w 01 15); do
    INSTANCE_PROFILE="${PROFILE_PREFIX}${i}${PROFILE_SUFFIX}${i}"
    
    echo "🛑 Deleting Instance Profile: $INSTANCE_PROFILE"

    # 존재 여부 확인
    if aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE" >/dev/null 2>&1; then
        # 인스턴스 프로파일 삭제
        aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE"
        echo "✅ Deleted: $INSTANCE_PROFILE"
    else
        echo "⚠️ Instance Profile $INSTANCE_PROFILE not found. Skipping."
    fi
done

echo "🎉 Instance Profile deletion process completed!"
