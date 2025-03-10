# 🚀 Cloud Infrastructure Automation

AWS 및 Kubernetes 기반 클라우드 인프라를 효율적으로 관리하기 위한 자동화 스크립트 및 IaC 코드를 포함하는 레포지토리입니다.

## 📂 디렉토리 구조
```
.
├── README.md                        # 프로젝트 개요 및 설명
├── assets/                           # 프로젝트 관련 이미지 및 파일
├── docs/                             # 문서화 관련 파일 (아키텍처 다이어그램, 설명서)
├── infra/                            # Infrastructure as Code (IaC) 관련 코드
│   ├── cloudformation-templates/    # AWS CloudFormation 템플릿
│   ├── terraform-scripts/           # Terraform을 활용한 인프라 배포 스크립트
├── projects/                         # 개별 프로젝트별 관리 디렉토리
├── scripts/                          # 운영 자동화 및 관리 스크립트
│   ├── aws/                          # AWS 관련 스크립트
│   │   ├── cloud9/                  # AWS Cloud9 설정 자동화
│   │   ├── eks/                     # Amazon EKS 관련 관리 스크립트
│   │   ├── iam/                     # IAM 역할 및 정책 관리 스크립트
│   │   ├── security/                # 보안 그룹 관리 스크립트
│   │   ├── service-catalog/         # AWS Service Catalog 자동화 스크립트
│   ├── kubernetes/                   # Kubernetes 관련 리소스 및 설정 파일
│   │   ├── workloads/               # Kubernetes Pod 및 Deployment 설정
│   │   ├── daemonsets/              # DaemonSet 리소스 관리 (NVIDIA GPU 등)
│   ├── lambda/                       # AWS Lambda 관련 스크립트
```

## 🔹 개요
이 레포지토리는 AWS 클라우드 및 Kubernetes 인프라 자동화를 위한 다양한 스크립트와 템플릿을 제공합니다.

## 📂 디렉토리 설명

- **`assets/`**: 프로젝트 관련 이미지, 다이어그램, 참고 파일 저장
- **`docs/`**: 문서화 관련 디렉토리 (예: 아키텍처 설명서, 가이드)
- **`infra/`**: Infrastructure as Code(IaC) 관련 코드 관리
  - `cloudformation-templates/` → AWS CloudFormation 템플릿
  - `terraform-scripts/` → Terraform을 활용한 인프라 배포 스크립트
- **`projects/`**: 프로젝트별 관리 디렉토리
- **`scripts/`**: AWS 및 Kubernetes 운영 자동화 스크립트
  - `aws/` → AWS 관련 자동화 스크립트
    - `cloud9/` → AWS Cloud9 개발 환경 설정
    - `eks/` → EKS 클러스터 및 노드 그룹 관리
    - `iam/` → IAM 역할 및 정책 설정
    - `security/` → 보안 그룹 및 네트워크 정책 관리
    - `service-catalog/` → AWS Service Catalog 자동화 배포
  - `kubernetes/` → Kubernetes 관련 리소스 및 설정 파일
    - `workloads/` → Kubernetes Pod 및 Deployment 설정
    - `daemonsets/` → NVIDIA GPU 관련 DaemonSet 관리
  - `lambda/` → AWS Lambda 관련 자동화 스크립트

---

## **🚀 설치 및 사용 방법**
1. **레포지토리 클론**
   ```bash
   git clone https://github.com/your-repo-name.git
   cd your-repo-name
   ```
2. **스크립트 실행**
   ```bash
   chmod +x scripts/aws/eks/create-gpu-nodegroups.sh
   ./scripts/aws/eks/create-gpu-nodegroups.sh
   ```
3. **Terraform 적용**
   ```bash
   cd infra/terraform-scripts
   terraform init
   terraform apply
   ```

---

## 🔹 기여 방법
1. **이슈 생성**: 버그나 개선 사항이 있다면 Issue를 생성해주세요.
2. **PR 요청**: 새로운 기능을 추가하거나 수정사항이 있다면 PR을 보내주세요.

🚀 **AWS 클라우드 자동화에 기여하고 싶다면 언제든지 환영합니다!** 🎉

