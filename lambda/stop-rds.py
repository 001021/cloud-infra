import boto3
import os
import sys
import time
from datetime import datetime, timezone
from time import gmtime, strftime

# 특정 태그가 있는 RDS 인스턴스를 자동으로 중지하는 함수
def shut_rds_all():
    # Lambda 환경 변수에서 리전(region), 태그 키(KEY), 태그 값(VALUE) 가져오기
    region = os.environ['REGION']
    key = os.environ['KEY']
    value = os.environ['VALUE']

    # RDS 클라이언트 생성
    client = boto3.client('rds', region_name=region)

    # 현재 AWS 계정 내의 모든 RDS 인스턴스를 조회
    response = client.describe_db_instances()

    # Read Replica(복제본) 목록을 저장할 리스트
    v_readReplica = []

    # Read Replica 식별자 수집 (각 인스턴스의 복제본을 리스트에 저장)
    for i in response['DBInstances']:
        readReplica = i['ReadReplicaDBInstanceIdentifiers']
        v_readReplica.extend(readReplica)  # 모든 Read Replica 추가

    # 개별 RDS 인스턴스 상태 확인 및 중지
    for i in response['DBInstances']:
        # Aurora 클러스터는 별도로 중지해야 하므로 여기서는 제외
        if i['Engine'] not in ['aurora-mysql', 'aurora-postgresql']:
            # Read Replica가 아니고, 다른 인스턴스를 복제하고 있지 않은 경우만 처리
            if i['DBInstanceIdentifier'] not in v_readReplica and len(i['ReadReplicaDBInstanceIdentifiers']) == 0:
                arn = i['DBInstanceArn']
                resp2 = client.list_tags_for_resource(ResourceName=arn)  # 해당 RDS의 태그 조회

                # 태그가 없는 경우 (자동 중지 대상이 아님)
                if len(resp2['TagList']) == 0:
                    print(f'DB Instance {i["DBInstanceIdentifier"]}은 자동 중지 그룹에 포함되지 않음.')
                else:
                    for tag in resp2['TagList']:
                        # KEY-VALUE 값이 일치하는 경우만 자동 중지
                        if tag['Key'] == key and tag['Value'] == value:
                            if i['DBInstanceStatus'] == 'available':
                                client.stop_db_instance(DBInstanceIdentifier=i['DBInstanceIdentifier'])
                                print(f'Stopping DB Instance {i["DBInstanceIdentifier"]}')
                            elif i['DBInstanceStatus'] == 'stopped':
                                print(f'DB Instance {i["DBInstanceIdentifier"]}는 이미 중지된 상태입니다.')
                            elif i['DBInstanceStatus'] == 'starting':
                                print(f'DB Instance {i["DBInstanceIdentifier"]}가 시작 중 상태입니다. 시작이 완료된 후 중지하세요.')
                            elif i['DBInstanceStatus'] == 'stopping':
                                print(f'DB Instance {i["DBInstanceIdentifier"]}는 이미 중지 중 상태입니다.')
                        else:
                            print(f'DB Instance {i["DBInstanceIdentifier"]}은 자동 중지 그룹에 포함되지 않음.')
            else:
                print(f'DB Instance {i["DBInstanceIdentifier"]}는 Read Replica이므로 자동 중지에서 제외됨.')

    # Aurora DB 클러스터 처리 (별도의 API 필요)
    response = client.describe_db_clusters()

    for i in response['DBClusters']:
        cluarn = i['DBClusterArn']
        resp2 = client.list_tags_for_resource(ResourceName=cluarn)

        # 태그가 없는 경우 (자동 중지 대상이 아님)
        if len(resp2['TagList']) == 0:
            print(f'DB Cluster {i["DBClusterIdentifier"]}은 자동 중지 그룹에 포함되지 않음.')
        else:
            for tag in resp2['TagList']:
                # KEY-VALUE 값이 일치하는 경우만 자동 중지
                if tag['Key'] == key and tag['Value'] == value:
                    if i['Status'] == 'available':
                        client.stop_db_cluster(DBClusterIdentifier=i['DBClusterIdentifier'])
                        print(f'Stopping DB Cluster {i["DBClusterIdentifier"]}')
                    elif i['Status'] == 'stopped':
                        print(f'DB Cluster {i["DBClusterIdentifier"]}는 이미 중지된 상태입니다.')
                    elif i['Status'] == 'starting':
                        print(f'DB Cluster {i["DBClusterIdentifier"]}가 시작 중 상태입니다. 시작이 완료된 후 중지하세요.')
                    elif i['Status'] == 'stopping':
                        print(f'DB Cluster {i["DBClusterIdentifier"]}는 이미 중지 중 상태입니다.')
                else:
                    print(f'DB Cluster {i["DBClusterIdentifier"]}은 자동 중지 그룹에 포함되지 않음.')

# AWS Lambda 핸들러 함수 (이벤트 발생 시 실행됨)
def lambda_handler(event, context):
    shut_rds_all()
