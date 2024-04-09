#! /bin/sh

set -u # `-e` omitted intentionally, but i can't remember why exactly :'(
set -o pipefail

source ./env.sh

s3_uri_base="s3://${S3_BUCKET}/${S3_PREFIX}"

if [ -z "$PASSPHRASE" ]; then
  file_type=".tar.gz"
else
  file_type=".tar.gz.gpg"
fi

if [ $# -eq 1 ]; then
  timestamp="$1"
  key_suffix="${BACKUP_FILE_NAME}_${timestamp}${file_type}"
else
  echo "Finding latest backup..."
  key_suffix=$(
    aws $aws_args s3 ls "${s3_uri_base}/${BACKUP_FILE_NAME}" \
      | sort \
      | tail -n 1 \
      | awk '{ print $4 }'
  )
fi

echo "Fetching backup from S3..."
aws $aws_args s3 cp "${s3_uri_base}/${key_suffix}" "${BACKUP_FILE_NAME}${file_type}"

if [ -n "$PASSPHRASE" ]; then
  echo "Decrypting backup..."
  gpg --decrypt --batch --passphrase "$PASSPHRASE" "${BACKUP_FILE_NAME}.tar.gz.gpg" > "${BACKUP_FILE_NAME}.tar.gz"
  rm "${BACKUP_FILE_NAME}.tar.gz.gpg"
fi

echo "Restoring from backup..."
tar -xf "${BACKUP_FILE_NAME}.tar.gz" --directory /home/backups
rm "${BACKUP_FILE_NAME}.tar.gz"

echo "Restore complete."
