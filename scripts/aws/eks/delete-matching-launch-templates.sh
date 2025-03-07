#!/bin/bash
set -e  # 오류 발생 시 즉시 종료

# AWS 리전 설정
REGION="ap-northeast-2"

# 삭제할 시작 템플릿 패턴
LT_PREFIXES=("eksnode-ct01-test-je-eks1.31" "eks-ct01-test-je-01-launch-template")

echo "🔍 Searching for launch templates with prefixes: ${LT_PREFIXES[*]}..."

# 특정 패턴을 포함하는 시작 템플릿 조회
LAUNCH_TEMPLATE_NAMES=()
for PREFIX in "${LT_PREFIXES[@]}"; do
    TEMPLATES=$(aws ec2 describe-launch-templates \
        --region "$REGION" \
        --query "LaunchTemplates[?starts_with(LaunchTemplateName, '$PREFIX')].LaunchTemplateName" \
        --output text)
    
    if [ -n "$TEMPLATES" ]; then
        LAUNCH_TEMPLATE_NAMES+=($TEMPLATES)
    fi
done

if [ ${#LAUNCH_TEMPLATE_NAMES[@]} -eq 0 ]; then
    echo "✅ No matching launch templates found. Nothing to delete."
    exit 0
fi

echo "🛑 The following launch templates will be deleted:"
printf "%s\n" "${LAUNCH_TEMPLATE_NAMES[@]}"

# 사용자 확인 (자동 실행하려면 아래 줄을 주석 처리)
read -p "⚠️  Are you sure you want to delete these launch templates? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

# 시작 템플릿 삭제
for TEMPLATE_NAME in "${LAUNCH_TEMPLATE_NAMES[@]}"; do
    echo "🚀 Deleting launch template: $TEMPLATE_NAME..."
    if aws ec2 delete-launch-template --launch-template-name "$TEMPLATE_NAME" --region "$REGION"; then
        echo "✅ Launch template '$TEMPLATE_NAME' deleted successfully!"
    else
        echo "❌ Failed to delete launch template '$TEMPLATE_NAME'. It may be in use by another resource."
    fi
done

echo "🎉 All matching launch templates have been processed!"
