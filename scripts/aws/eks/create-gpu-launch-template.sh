#!/bin/bash

# 변수 설정
REGION="ap-northeast-2"
SOURCE_TEMPLATE_NAME="eks-ct01-test-je-02-launch-template-2025030701153887470000000e"
NEW_TEMPLATE_NAME="eksnode-ct01-test-je-eks1.31-gpu-$(date +'%Y%m%d%H%M%S')"
AMI_ID="ami-0ae34dd38e95de82a"

# 인스턴스 유형, 스토리지 크기, max-pods 매핑
declare -A INSTANCE_CONFIGS=(
  ['g4dn_xlarge_50GB']="50|20"
  ['g4dn_xlarge_100GB']="100|20"
  ['g4dn_xlarge_200GB']="200|20"
)

# 원본 시작 템플릿 정보 가져오기
echo "🔍 Fetching source launch template data..."
SOURCE_TEMPLATE_DATA=$(aws ec2 describe-launch-template-versions \
  --region "$REGION" \
  --launch-template-name "$SOURCE_TEMPLATE_NAME" \
  --versions "1" \
  --query "LaunchTemplateVersions[0].LaunchTemplateData" \
  --output json)

if [ -z "$SOURCE_TEMPLATE_DATA" ]; then
  echo "❌ Error: Unable to fetch source launch template data."
  exit 1
fi

# 원본 Security Group & Metadata Options 가져오기
SECURITY_GROUPS=$(echo "$SOURCE_TEMPLATE_DATA" | jq -c '.SecurityGroupIds')
METADATA_OPTIONS=$(echo "$SOURCE_TEMPLATE_DATA" | jq -c '.MetadataOptions')

# 원본 User Data 가져오기 및 Base64 디코딩
SOURCE_USER_DATA_ENCODED=$(echo "$SOURCE_TEMPLATE_DATA" | jq -r '.UserData')
SOURCE_USER_DATA=$(echo "$SOURCE_USER_DATA_ENCODED" | base64 --decode)

# 1번 버전 생성
BASE_CONFIG="g4dn_xlarge_50GB"
BASE_STORAGE_SIZE=$(echo "${INSTANCE_CONFIGS[$BASE_CONFIG]}" | cut -d'|' -f1)
BASE_MAX_PODS=$(echo "${INSTANCE_CONFIGS[$BASE_CONFIG]}" | cut -d'|' -f2)

echo "🚀 Creating initial launch template ($NEW_TEMPLATE_NAME) with $BASE_CONFIG..."

MODIFIED_USER_DATA=$(echo "$SOURCE_USER_DATA" | sed "s/--max-pods=[0-9]*/--max-pods=$BASE_MAX_PODS/")
ENCODED_USER_DATA=$(echo -n "$MODIFIED_USER_DATA" | base64 --wrap=0)

echo "ENCODED_USER_DATA"

aws ec2 create-launch-template \
  --region "$REGION" \
  --launch-template-name "$NEW_TEMPLATE_NAME" \
  --version-description "$BASE_CONFIG" \
  --launch-template-data "{
    \"ImageId\": \"$AMI_ID\",
    \"BlockDeviceMappings\": [{
      \"DeviceName\": \"/dev/xvda\",
      \"Ebs\": {
        \"VolumeSize\": $BASE_STORAGE_SIZE,
        \"VolumeType\": \"gp3\",
        \"Iops\": 3000,
        \"Throughput\": 125,
        \"DeleteOnTermination\": true,
        \"Encrypted\": false
      }
    }],
    \"SecurityGroupIds\": $SECURITY_GROUPS,
    \"MetadataOptions\": $METADATA_OPTIONS,
    \"TagSpecifications\": [{
      \"ResourceType\": \"instance\",
      \"Tags\": [
        {\"Key\": \"Name\", \"Value\": \"kt-sc-ct01-eks-ct01-test-je-02-nodegrp\"},
        {\"Key\": \"Backup\", \"Value\": \"velero_Daily_1AM\"}
      ]
    }],
    \"UserData\": \"$ENCODED_USER_DATA\"
  }"

if [ $? -ne 0 ]; then
  echo "❌ Error: Failed to create initial launch template."
  exit 1
fi

# 2번 버전부터 추가
VERSION=2
for CONFIG in "g4dn_xlarge_100GB" "g4dn_xlarge_200GB"; do
  STORAGE_SIZE=$(echo "${INSTANCE_CONFIGS[$CONFIG]}" | cut -d'|' -f1)
  MAX_PODS=$(echo "${INSTANCE_CONFIGS[$CONFIG]}" | cut -d'|' -f2)

  MODIFIED_USER_DATA=$(echo "$SOURCE_USER_DATA" | sed "s/--max-pods=[0-9]*/--max-pods=$MAX_PODS/")
  ENCODED_USER_DATA=$(echo -n "$MODIFIED_USER_DATA" | base64 --wrap=0)

  echo "🚀 Creating launch template version: $VERSION ($CONFIG)..."

  aws ec2 create-launch-template-version \
    --region "$REGION" \
    --launch-template-name "$NEW_TEMPLATE_NAME" \
    --version-description "$CONFIG" \
    --source-version "1" \
    --launch-template-data "{
      \"BlockDeviceMappings\": [{
        \"DeviceName\": \"/dev/xvda\",
        \"Ebs\": {
          \"VolumeSize\": $STORAGE_SIZE,
          \"VolumeType\": \"gp3\",
          \"Iops\": 3000,
          \"Throughput\": 125,
          \"DeleteOnTermination\": true,
          \"Encrypted\": false
        }
      }],
      \"UserData\": \"$ENCODED_USER_DATA\"
    }"

  if [ $? -eq 0 ]; then
    echo "✅ Created version $VERSION ($CONFIG)"
  else
    echo "❌ Failed to create version $VERSION ($CONFIG)"
  fi

  ((VERSION++))
done

echo "✅ GPU EKS Launch Template Created Successfully!"
