#!/bin/bash
set -e  # 오류 발생 시 즉시 종료

# .env 파일 로드
if [ -f .env ]; then
    source .env
else
    echo "❌ .env 파일을 찾을 수 없습니다. .env.example을 참고하여 생성하세요."
    exit 1
fi

# 프로비저닝된 제품 이름 설정
PROVISIONED_PRODUCT_NAME="eks-ct01-test-${SERVICE_NAME}-${SEQUENCE_NUMBER}"

echo "🔍 Finding provisioned product ID for: $PROVISIONED_PRODUCT_NAME"

# 프로비저닝된 제품 ID 조회
PRODUCT_ID=$(aws servicecatalog search-provisioned-products \
    --region "$AWS_REGION" \
    --query "ProvisionedProducts[?Name=='$PROVISIONED_PRODUCT_NAME'].Id" \
    --output text)

# 제품이 존재하는지 확인
if [ -z "$PRODUCT_ID" ]; then
    echo "✅ No provisioned product found with name '$PROVISIONED_PRODUCT_NAME'. Nothing to terminate."
    exit 0
fi

echo "🚀 Terminating provisioned product: $PROVISIONED_PRODUCT_NAME (ID: $PRODUCT_ID)"

# Service Catalog 제품 종료 요청
aws servicecatalog terminate-provisioned-product \
    --region "$AWS_REGION" \
    --provisioned-product-id "$PRODUCT_ID" \
    --ignore-errors

echo "✅ Provisioned product '$PROVISIONED_PRODUCT_NAME' has been successfully terminating!"
