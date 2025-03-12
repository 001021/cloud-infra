import boto3

# 실행할 AWS 리전 설정
region = 'ap-northeast-2'

# 중지할 인스턴스를 저장할 리스트
instances = []

# EC2 리소스 및 클라이언트 생성
ec2_r = boto3.resource('ec2')  # EC2 리소스 객체 (고수준 API)
ec2 = boto3.client('ec2', region_name=region)  # EC2 클라이언트 객체 (저수준 API)

# 모든 EC2 인스턴스를 순회하며 특정 태그가 있는 인스턴스 필터링
for instance in ec2_r.instances.all():
    for tag in instance.tags:
        if tag['Key'] == 'auto-schedule':  # 태그 이름이 'auto-schedule'인지 확인
            if tag['Value'] == 'True':  # 태그 값이 'True'이면 중지할 인스턴스 목록에 추가
                instances.append(instance.id)

# AWS Lambda 핸들러 함수 (이벤트 트리거 시 실행됨)
def lambda_handler(event, context):
    if instances:  # 중지할 인스턴스가 있을 경우
        ec2.stop_instances(InstanceIds=instances)  # 인스턴스 중지
        print('Stopped instances: ' + str(instances))
    else:
        print('No instances to stop')
