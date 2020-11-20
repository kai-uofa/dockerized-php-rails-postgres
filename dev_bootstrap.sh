#!/bin/bash

# Usage:
#   chmod +x ./dev_bootstrap.sh
#   ./dev_bootstrap.sh $RAIL_GIT_URL $API_GIT_URL $DATABASE_BACKUP_PATH $RUBY_VERSION $RUBY_RAIL_GEMSET $RUBY_API_GEMSET

RAIL_GIT_URL=$1
API_GIT_URL=$2
DATABASE_BACKUP_PATH=$3

RUBY_VERSION=$4
RUBY_RAIL_GEMSET=$5
RUBY_API_GEMSET=$6

# Clone rails
git clone ${RAIL_GIT_URL} ../rails
# Update rails configurations
echo ${RUBY_VERSION} > ../rails/.ruby-version
echo ${RUBY_RAIL_GEMSET} > ../rails/.ruby-gemset
cp ./dev-configs/database.yml.docker ../rails/config/database.yml

# Clone api
git clone ${API_GIT_URL} ../php-api
# Update api configurations
echo ${RUBY_VERSION} > ../rails/.ruby-version
echo ${RUBY_API_GEMSET} > ../rails/.ruby-gemset
cp ./dev-configs/config.php.docker ../php-api/config.php

# Download database backup
if [[ ${DATABASE_BACKUP_PATH} == http* ]] ;
then
    curl ${DATABASE_BACKUP_PATH} > ./dev-configs/database_backup.gz
else
    mv ${DATABASE_BACKUP_PATH} ./dev-configs/database_backup.gz
fi

# Preparing dev config for building docker image
mkdir ./dev-configs/php-api
cp ../php-api/Gemfile ./dev-configs/php-api/Gemfile
cp ../php-api/Gemfile.lock ./dev-configs/php-api/Gemfile.lock
cp ../php-api/.ruby-gemset ./dev-configs/php-api/.ruby-gemset
cp ../php-api/.ruby-version ./dev-configs/php-api/.ruby-version

mkdir ./dev-configs/rails
cp ../rails/Gemfile ./dev-configs/rails/Gemfile
cp ../rails/Gemfile.lock ./dev-configs/rails/Gemfile.lock
cp ../rails/.ruby-gemset ./dev-configs/rails/.ruby-gemset
cp ../rails/.ruby-version ./dev-configs/rails/.ruby-version

# Build development docker images
docker-compose build

# Remove vendor folder if exist
if [ -d "../php-api/vendor" ]; then
    rm -rf ../php-api/vendor
fi
# Install composer packages on development
docker-compose run development composer install

# Clean up docker: all stopped containers, all networks not used by at least 1 container, all dangling images and build caches.
docker system prune

# Clean up temporary files
if [ -d "./dev-configs/php-api" ]; then
    rm -rf ./dev-configs/php-api
fi

if [ -d "./dev-configs/rails" ]; then
    rm -rf ./dev-configs/rails
fi

# Set execute bit for ./dev-configs/db_init.sh
chmod +x ./dev-configs/db_init.sh

# Runs development dockers
docker-compose up --detach