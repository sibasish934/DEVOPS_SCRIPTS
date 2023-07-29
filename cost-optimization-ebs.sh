import boto3

def is_volume_attached_to_running_instance(volume_id):
    ec2 = boto3.client('ec2')
    response = ec2.describe_volumes(VolumeIds=[volume_id])

    if 'Volumes' in response and len(response['Volumes']) == 1:
        volume = response['Volumes'][0]
        attachments = volume.get('Attachments', [])
        for attachment in attachments:
            if attachment['State'] == 'attached':
                instance_id = attachment['InstanceId']
                response = ec2.describe_instances(InstanceIds=[instance_id])
                if 'Reservations' in response and len(response['Reservations']) == 1:
                    instances = response['Reservations'][0]['Instances']
                    for instance in instances:
                        if instance['State']['Name'] == 'running':
                            return True

    return False

def delete_snapshots_without_attached_volumes():
    ec2 = boto3.client('ec2')
    response = ec2.describe_snapshots(OwnerIds=['self'])

    for snapshot in response['Snapshots']:
        snapshot_id = snapshot['SnapshotId']
        volume_id = snapshot['VolumeId']
        
        if not is_volume_attached_to_running_instance(volume_id):
            print(f"Deleting snapshot {snapshot_id} associated with volume {volume_id}")
            ec2.delete_snapshot(SnapshotId=snapshot_id)
        else:
            print(f"Snapshot {snapshot_id} associated with volume {volume_id} is not eligible for deletion.")

if __name__ == "__main__":
    delete_snapshots_without_attached_volumes()
