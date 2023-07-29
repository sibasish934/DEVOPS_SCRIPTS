#!/bin/bash

# Replace these variables with your actual values
DB_USER="your_database_username"
DB_PASSWORD="your_database_password"
DB_NAME="your_database_name"
S3_BUCKET="your_s3_bucket_name"
S3_KEY="backup_folder/backup_file.sql"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="backup_${TIMESTAMP}.sql"

# Dump the database to a local file
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILENAME

# Check if the backup file was created successfully
if [ -s $BACKUP_FILENAME ]; then
    echo "Database backup successful: $BACKUP_FILENAME"

    # Upload the backup file to S3
    aws s3 cp $BACKUP_FILENAME s3://$S3_BUCKET/$S3_KEY

    # Check if the upload was successful
    if [ $? -eq 0 ]; then
        echo "Backup uploaded to S3: s3://$S3_BUCKET/$S3_KEY"
        # Optionally, you can remove the local backup file after successful upload
        # rm $BACKUP_FILENAME
    else
        echo "Error uploading backup to S3."
    fi
else
    echo "Error creating database backup."
fi
