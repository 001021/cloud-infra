import boto3
from botocore.exceptions import ClientError

def create_vpc_endpoints(vpc_id, service_names):
    """
    지정된 VPC에 VPC 엔드포인트를 생성하는 함수
    """
    ec2_client = boto3.client('ec2')
    created_endpoints = []

    for service_name in service_names:
        try:
            response = ec2_client.create_vpc_endpoint(
                VpcId=vpc_id,
                ServiceName=service_name,
                VpcEndpointType='Interface',  # 'Interface' or 'Gateway'
                PrivateDnsEnabled=False,
                SubnetIds=['subnet-0cb39312277074581', 'subnet-02cd2e720e610312d'],
                SecurityGroupIds=['sg-04e7e53bbf08421cd'],
            )
            created_endpoints.append(response['VpcEndpoint']['VpcEndpointId'])
            print(f"✅ Created VPC Endpoint: {response['VpcEndpoint']['VpcEndpointId']} for service: {service_name}")
        except ClientError as e:
            print(f"❌ Failed to create VPC Endpoint for service: {service_name}, error: {e}")

    return created_endpoints
    
def get_vpc_endpoints(vpc_id):
    """
    VPC 내 모든 VPC 엔드포인트 정보를 가져오는 함수
    """
    client = boto3.client('ec2')
    response = client.describe_vpc_endpoints(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
    endpoints = {}
    for endpoint in response['VpcEndpoints']:
        service_name_components = endpoint['ServiceName'].split('.')
        service_name = service_name_components[-1]

        dns_names = endpoint['DnsEntries']
        
        if dns_names:
            endpoints[service_name] = {
                'DnsName': dns_names[0]['DnsName'],
                'HostedZoneId': dns_names[0]['HostedZoneId']
            }
    return endpoints


def add_a_records_to_all_hosted_zones(vpc_id):
    """
    모든 Hosted Zone에 A 레코드를 추가하는 함수
    """
    client = boto3.client('route53')
    vpc_endpoints = get_vpc_endpoints(vpc_id)

    hosted_zones = {
        "Z05560071C7EBM2SW305C": "autoscaling",
        "Z0587738O4ULJ3YQPQUA": "ec2",
        "Z0279741FDQMEHVGEBA3": "ec2messages",
        "Z01491742ICHYY5IYG02B": "api.ecr",
        "Z05824483IW4U14XJ2N27": "dkr.ecr",
        "Z0607934YF3MR2S3V39U": "elasticfilesystem",
        "Z0606532200ZYN9C1F6CL": "elasticloadbalancing",
        "Z0524791JSTJCHHCBJBQ": "kms",
        "Z06095002AD4P88CQ38SS": "logs",
        "Z01547793MR3TZ6VLQ6J5": "monitoring",
        "Z0433840363WVD8OWQ1TU": "ssm",
        "Z021764638PMTPYOZD8MI": "ssmmessages",
        "Z0587186W34MYET6VZOM": "sts",
    }
    
    for zone_id, service in hosted_zones.items():
        if service in vpc_endpoints:
            endpoint_info = vpc_endpoints[service]
            dns_name = endpoint_info['DnsName']
            hosted_zone_id = endpoint_info['HostedZoneId']
            response = client.change_resource_record_sets(
                HostedZoneId=zone_id,
                ChangeBatch={
                    'Changes': [{
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': f'{service}.ap-northeast-2.amazonaws.com',
                            'Type': 'A',
                            'AliasTarget': {
                                'HostedZoneId': hosted_zone_id,
                                'DNSName': dns_name,
                                'EvaluateTargetHealth': False
                            }
                        }
                    }]
                }
            )
            print(f"✅ Created A Record: {service}.ap-northeast-2.amazonaws.com -> {dns_name}")
        else:
            print(f"⚠️ No VPC endpoint found for {service}. Skipping...")

def lambda_handler(event, context):
    """
    AWS Lambda 핸들러 함수
    """
    vpc_id = 'vpc-07810d98b7fbd66b2'
    service_names = [
        'com.amazonaws.ap-northeast-2.ssm',
        'com.amazonaws.ap-northeast-2.ssmmessages',
        'com.amazonaws.ap-northeast-2.ec2messages',
        'com.amazonaws.ap-northeast-2.kms',
        'com.amazonaws.ap-northeast-2.ecr.api',
        'com.amazonaws.ap-northeast-2.ecr.dkr',
        'com.amazonaws.ap-northeast-2.ec2',
        'com.amazonaws.ap-northeast-2.monitoring',
        'com.amazonaws.ap-northeast-2.logs',
        'com.amazonaws.ap-northeast-2.elasticfilesystem',
        'com.amazonaws.ap-northeast-2.elasticloadbalancing',
        'com.amazonaws.ap-northeast-2.sts',
        'com.amazonaws.ap-northeast-2.autoscaling'
    ]

    created_endpoints = create_vpc_endpoints(vpc_id, service_names)
    add_a_records_to_all_hosted_zones(vpc_id)

    return {
        'statusCode': 200,
        'body': f"✅ Successfully created VPC endpoints and A records."
    }
