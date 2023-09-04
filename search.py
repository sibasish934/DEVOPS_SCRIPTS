import boto3
from boto3 import Session

def find_files_in_bucket(bucket_name, file_name):
    # Initialize the S3 client
    s3 = boto3.client('s3')

    # Create a paginator to list objects
    paginator = s3.get_paginator('list_objects_v2')

    matching_files = []

    # Use the paginator to iterate through all pages of objects in the bucket
    for page in paginator.paginate(Bucket=bucket_name):
        for obj in page.get('Contents', []):
            if file_name in obj['Key']:
                matching_files.append(obj['Key'])

    return matching_files


def download_file_from_s3(bucket_name, file_key, local_path):
    try:
        # Initialize the S3 client
        s3 = boto3.client('s3')
        # Download the file from S3 to the local system
        s3.download_file(bucket_name, file_key, local_path)
        return True
    except Exception as e:
        print("Some Error Ocuured while downloading the file \n")
        print(f"Error: {str(e)}")
        return False


if __name__ == "__main__":

    # setting the aws credentials in order to authorize the program to aws.
    session = Session()
    credentials = session.get_credentials()
    current_credentials = credentials.get_frozen_credentials()

    bucket_name = 'testsiliconbucket'
    file_name = 'testing.jpg'
    
    local_path = r'C:\Users\hp\Downloads' + "\\"+ file_name

    print(local_path)

    result = find_files_in_bucket(bucket_name, file_name)

    if result:
        print(f"Matching files in '{bucket_name}':")
        for file in result:
            print(f"The File path is:- s3://{bucket_name}/{file}")
            download_file_from_s3(bucket_name, file, local_path)
    else:
        print(f"No matching files found in '{bucket_name}' for '{file_name}'.")
