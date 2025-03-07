# 🚀 AWS Service Catalog EKS GPU AMI 배포 스크립트

이 스크립트는 AWS Service Catalog를 사용하여 **EKS 클러스터, NodeGroup, IAM Role, Security Group, 시작 템플릿 등을 배포**합니다.

## 📌 사전 요구 사항
1. AWS CLI가 설치되어 있어야 합니다.  
2. AWS IAM 권한이 있어야 합니다 (`servicecatalog:ProvisionProduct` 필요).  
3. `.env` 파일을 생성해야 합니다.

## ⚙️ 환경 변수 설정
1. `.env.example` 파일을 참고하여 `.env` 파일을 생성하세요.
```bash
cp .env.example .env
```
2. `.env` 파일을 열고 필요한 정보를 입력하세요.

## 🚀 실행 방법
```bash
chmod +x provision-eks-gpu.sh
./provision-eks-gpu.sh
```

## 🛠 문제 해결
- `❌ .env 파일을 찾을 수 없습니다.` → `.env` 파일을 생성했는지 확인하세요.
- `An error occurred (AccessDeniedException) when calling the ProvisionProduct operation:` → IAM 권한이 있는지 확인하세요.
```
✅ Service Catalog 배포가 완료되면 EKS 클러스터가 생성됩니다!
```
