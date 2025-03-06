# 🚀 Cloud Infrastructure Portfolio  

이 저장소는 **AWS 및 Kubernetes 인프라 운영 자동화**를 위한 코드 및 문서를 포함합니다.  
EKS 클러스터 운영, IAM Role 관리, CloudWatch 비용 최적화, Terraform 기반 인프라 배포 등의 내용을 다룹니다.

## 📂 디렉토리 구조
```
cloud-infra-portfolio
├── 📂 scripts                # 운영 자동화 스크립트
│   ├── 📂 aws               # AWS 관련 스크립트
│   │   ├── delete-iam-roles.sh  # IAM Role 삭제 자동화
│   │   ├── cloudwatch-cost-optimizer.sh  # CloudWatch 비용 최적화
│   │   ├── ...
│   ├── 📂 kubernetes        # Kubernetes 관련 스크립트 (EKS 관리)
│   │   ├── eks-upgrade.sh   # EKS 클러스터 업그레이드 자동화
│   │   ├── deploy-velero.sh # Velero 백업 설정
│   │   ├── ...
│   ├── 📂 lambda            # Lambda 기반 운영 자동화 스크립트
│
├── 📂 infra                 # 인프라 코드 (IaC)
│   ├── 📂 cloudformation-templates
│   ├── 📂 terraform-scripts
│
├── 📂 docs                   # 문서 및 정리된 자료
│   ├── AWS-Cost-Optimization.md  # AWS 비용 최적화 가이드
│   ├── Kubernetes-Guide.md       # EKS 운영 가이드
│
├── 📂 projects               # 프로젝트별 코드 모음
│   ├── 📂 release-notes-sharing  # Kakao i Cloud 기반 프로젝트
│
└── README.md                 # 저장소 개요 (현재 파일)
```


## 🚀 주요 기능
✅ **AWS 운영 자동화**
- IAM Role 관리 (생성, 삭제)
- CloudWatch 로그 비용 최적화
- S3, EC2, VPC 네트워크 관리 스크립트

✅ **Kubernetes(EKS) 관리**
- EKS 클러스터 업그레이드 (`eks-upgrade.sh`)
- Velero를 활용한 백업 & 복구 (`deploy-velero.sh`)
- ArgoCD 및 인프라 배포 자동화

✅ **Infrastructure as Code (IaC)**
- Terraform을 이용한 VPC, EC2, IAM, EKS 설정
- CloudFormation 템플릿 모음

✅ **운영 자동화 & 비용 최적화**
- AWS Lambda 기반 운영 자동화 스크립트
- CloudWatch Logs → S3 아카이빙 자동화


## 🛠 기술 스택
- **Cloud:** AWS (EKS, IAM, CloudWatch, S3, EC2, Lambda)
- **Kubernetes:** Amazon EKS, Helm, Velero, ArgoCD
- **Infrastructure as Code:** Terraform, AWS CloudFormation
- **Scripting & Automation:** Bash, AWS CLI, Python
- **Monitoring & Logging:** CloudWatch, Fluent Bit


## 📌 사용 방법
1. **IAM Role 삭제 자동화 실행**
   ```bash
   chmod +x scripts/aws/delete-iam-roles.sh
   ./scripts/aws/delete-iam-roles.sh
   ```
2. **EKS 클러스터 업그레이드**
   ```bash
   chmod +x scripts/kubernetes/eks-upgrade.sh
   ./scripts/kubernetes/eks-upgrade.sh
   ```

3. **CloudWatch 로그 비용 최적화**
   ```bash
   chmod +x scripts/aws/cloudwatch-cost-optimizer.sh
   ./scripts/aws/cloudwatch-cost-optimizer.sh
   ```

## 📜 문서 및 가이드
- [AWS 비용 최적화 가이드](docs/AWS-Cost-Optimization.md)
- [EKS 운영 가이드](docs/Kubernetes-Guide.md)
- [Terraform 기반 인프라 구축](docs/Terraform-Guide.md)


## 📌 추가할 내용
- [ ] CI/CD 자동화 (GitHub Actions 추가)
- [ ] 추가적인 AWS Lambda 운영 자동화 스크립트
- [ ] 더 많은 Kubernetes 운영 자동화 코드

---

## 📢 Contact
이 프로젝트에 대한 피드백이나 문의 사항이 있다면 언제든지 연락 주세요! 😊  