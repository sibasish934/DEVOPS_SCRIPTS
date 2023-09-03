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

if __name__ == "__main__":

    session = Session()
    credentials = session.get_credentials()
    current_credentials = credentials.get_frozen_credentials()

    bucket_name = 'testsiliconbucket'
    file_name = 'Algoanalytics.docx'

    result = find_files_in_bucket(bucket_name, file_name)

    if result:
        print(f"Matching files in '{bucket_name}':")
        for file in result:
            print(file)
    else:
        print(f"No matching files found in '{bucket_name}' for '{file_name}'.")
