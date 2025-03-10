import boto3
from botocore.exceptions import ClientError

def delete_vpc_endpoints():
    """
    모든 VPC 엔드포인트를 삭제하는 함수
    """
    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_vpc_endpoints()
        endpoints = response['VpcEndpoints']
    except ClientError as e:
        print(f"❌ VPC 엔드포인트 조회 실패: {e}")
        return

    if not endpoints:
        print("✅ 삭제할 VPC 엔드포인트가 없습니다.")
        return

    for endpoint in endpoints:
        endpoint_id = endpoint['VpcEndpointId']
        try:
            ec2.delete_vpc_endpoints(VpcEndpointIds=[endpoint_id])
            print(f"✅ VPC 엔드포인트 삭제 완료: {endpoint_id}")
        except ClientError as e:
            print(f"❌ VPC 엔드포인트 {endpoint_id} 삭제 실패: {e}")

def delete_a_records():
    """
    모든 Hosted Zone에서 A 레코드를 삭제하는 함수
    """
    client = boto3.client('route53')

    hosted_zones = client.list_hosted_zones()
    
    for zone in hosted_zones['HostedZones']:
        zone_id = zone['Id']
        zone_name = zone['Name']
        
        record_sets = client.list_resource_record_sets(HostedZoneId=zone_id)
        
        for record_set in record_sets['ResourceRecordSets']:
            if record_set['Type'] == 'A':
                change_batch = {
                    'Comment': 'A 레코드 삭제',
                    'Changes': [{
                        'Action': 'DELETE',
                        'ResourceRecordSet': record_set
                    }]
                }
                
                try:
                    client.change_resource_record_sets(
                        HostedZoneId=zone_id,
                        ChangeBatch=change_batch
                    )
                    print(f"✅ '{zone_name}'에서 A 레코드 삭제 완료.")
                except ClientError as e:
                    print(f"❌ '{zone_name}'에서 A 레코드 삭제 실패: {e}")

def lambda_handler(event, context):
    """
    AWS Lambda 핸들러 함수
    """
    delete_vpc_endpoints()  # VPC 엔드포인트 삭제
    delete_a_records()  # A 레코드 삭제
    
    return {
        'statusCode': 200,
        'body': '✅ 모든 VPC 엔드포인트와 A 레코드 삭제 완료'
    }
