#!/bin/bash

# === [ 사용자 정의 변수 ] ===
PROJECT="backendai"
ENV="test"
LOCATION="koreacentral"
LOCATION_CODE="krc"  # 지역 코드 지정
VM_SIZE="Standard_D2s_v3"
SSH_KEY="~/.ssh/azure_vm_test_key.pub"

# === [ 네이밍 규칙에 따라 리소스명 자동 생성 ] ===
RESOURCE_GROUP="rg-${ENV}-${LOCATION_CODE}-${PROJECT}"
VNET_NAME="vnet-${ENV}-${LOCATION_CODE}-${PROJECT}"
PUBLIC_SUBNET="subnet-public-${ENV}-${LOCATION_CODE}-${PROJECT}"
PRIVATE_SUBNET="subnet-private-${ENV}-${LOCATION_CODE}-${PROJECT}"
VM_NAME="vm-ai-${ENV}-${LOCATION_CODE}-${PROJECT}-01"
NSG_NAME="nsg-${ENV}-${LOCATION_CODE}-${PROJECT}"

# === [ 공통 태그 설정 ] ===
TAGS="env=${ENV} project=${PROJECT} created-by=cli"

# === [ 리소스 그룹 생성 ] ===
echo "🔹 리소스 그룹 생성: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION --tags $TAGS

# === [ VNet 및 서브넷 생성 ] ===
echo "🔹 VNet 및 서브넷 생성: $VNET_NAME"
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $PUBLIC_SUBNET \
  --subnet-prefix 10.0.0.0/24 \
  --tags $TAGS

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $PRIVATE_SUBNET \
  --address-prefix 10.0.1.0/24 \
  --tags $TAGS

# === [ 네트워크 보안 그룹(NSG) 생성 및 규칙 추가 ] ===
echo "🔹 네트워크 보안 그룹 생성: $NSG_NAME"
az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME --tags $TAGS

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name AllowSSH \
  --protocol Tcp --direction Inbound --priority 1000 --source-address-prefixes "*" \
  --source-port-ranges "*" --destination-port-ranges 22 --access Allow

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name AllowHTTP \
  --protocol Tcp --direction Inbound --priority 1001 --source-address-prefixes "*" \
  --source-port-ranges "*" --destination-port-ranges 80 --access Allow

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name AllowHTTP \
  --protocol Tcp --direction Inbound --priority 1001 --source-address-prefixes "*" \
  --source-port-ranges "*" --destination-port-ranges 8090 --access Allow

# === [ VM 생성 ] ===
echo "🔹 VM 생성: $VM_NAME"
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size $VM_SIZE \
  --location $LOCATION \
  --admin-username azureuser \
  --ssh-key-values $SSH_KEY \
  --vnet-name $VNET_NAME \
  --subnet $PUBLIC_SUBNET \
  --priority Spot \
  --eviction-policy Deallocate \
  --os-disk-size-gb 50 \
  --nsg $NSG_NAME \
  --tags $TAGS

echo "✅ Azure 리소스 배포 완료!"
