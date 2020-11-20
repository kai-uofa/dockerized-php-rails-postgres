#!/bin/bash

# Create dev database
psql -a -e --username postgres -c "CREATE DATABASE ${DEV_DATABASE_NAME};"

# Create and grant permission on dev database for dev user
psql -a -e --username postgres -c "CREATE USER ${DATABASE_USER} WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD '${DATABASE_PASSWORD}';"
psql -a -e --username postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DEV_DATABASE_NAME} TO ${DATABASE_USER};"

psql -a -e --username postgres -c "CREATE USER ${DB_USER_NAME} WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD '${DB_PASSWORD}';"
psql -a -e --username postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DEV_DATABASE_NAME} TO ${DB_USER_NAME};"

# Import data to dev database
BACKUP_FILE=$(find /home -maxdepth 1 -type f | grep ".gz")
if [ -f "${BACKUP_FILE}" ]; then
    echo "Restoring database. This might take a while..."
    gunzip < ${BACKUP_FILE} | psql --username postgres ${DEV_DATABASE_NAME}
fi