#!/bin/bash

# Usage:
#   chmod +x ./dev_bootstrap.sh
#   ./dev_bootstrap.sh $DATABASE_BACKUP_PATH $RAIL_GIT_URL $RAIL_BRANCH $API_GIT_URL $API_BRANCH $RUBY_VERSION $RUBY_RAIL_GEMSET $RUBY_API_GEMSET

DATABASE_BACKUP_PATH=$1

if [[ ${2} == http* ]] || [[ ${2} == git* ]]; then
    RAIL_GIT_URL=$2
else
    echo "[WARNING] No Rails git URL. Please make sure you have your Rails repository locally."
    RAIL_GIT_URL=''
fi

if [ -z "$3" ]; then
    echo "[WARNING] No Rails branch is set, using master branch."
    RAIL_BRANCH='master'
else
    RAIL_BRANCH=$3
fi

if [[ ${4} == http* ]] || [[ ${4} == git* ]]; then
    API_GIT_URL=$4
else
    echo "[WARNING] No API git URL. Please make sure you have your API repository locally."
    API_GIT_URL=''
fi

if [ -z "$5" ]; then
    echo "[WARNING] No API branch is set, using master branch."
    API_BRANCH='live'
else
    API_BRANCH=$5
fi

if [ -z "$6" ]; then
    echo "[WARNING] No Ruby version is set. Using default version."
    RUBY_VERSION='2.4.9'
else
    RUBY_VERSION=$6
fi

if [ -z "$7" ]; then
    echo "[WARNING] No Gemset name for Rails is set. Using default name."
    RUBY_RAIL_GEMSET='gemset_rails'
else
    RUBY_RAIL_GEMSET=$7
fi

if [ -z "$8" ]; then
    echo "[WARNING] No Gemset name for API is set. Using default name."
    RUBY_API_GEMSET='gemset_api'
else
    RUBY_API_GEMSET=$8
fi

RAILS_DIRECTORY='rails'
PHP_DIRECTORY='php-api'
POSTGRES_DIRECTORY='postgres-data'

# Create default .env file for docker-compose
echo "RUBY_VERSION=${RUBY_VERSION}" > ./.env
echo "RAILS_DIRECTORY=${RAILS_DIRECTORY}" >> ./.env
echo "PHP_DIRECTORY=${PHP_DIRECTORY}" >> ./.env
echo "POSTGRES_DIRECTORY=${POSTGRES_DIRECTORY}" >> ./.env

# Clone rails
if [ -z "$RAIL_GIT_URL" ]; then
    echo "[WARNING] Using local repository. Please make sure you have your Rails repository at ../${RAILS_DIRECTORY}"
else
    git clone ${RAIL_GIT_URL} ../${RAILS_DIRECTORY}
fi
# Update rails configurations
echo ${RUBY_VERSION} > ../${RAILS_DIRECTORY}/.ruby-version
echo ${RUBY_RAIL_GEMSET} > ../${RAILS_DIRECTORY}/.ruby-gemset
cp ./dev-configs/database.yml.docker ../${RAILS_DIRECTORY}/config/database.yml

# Clone api
if [ -z "$API_GIT_URL" ]; then
    echo "[WARNING] Using local repository. Please make sure you have your API repository at ../${PHP_DIRECTORY}"
else
    git clone ${API_GIT_URL} ../${PHP_DIRECTORY}
fi
# Update api configurations
echo ${RUBY_VERSION} > ../${PHP_DIRECTORY}/.ruby-version
echo ${RUBY_API_GEMSET} > ../${PHP_DIRECTORY}/.ruby-gemset
cp ./dev-configs/config.php.docker ../${PHP_DIRECTORY}/config.php

# Copy .vscode folder to support PHP debug
cp -R ./.vscode/ ../${PHP_DIRECTORY}/.vscode

# Download database backup
if [ -z "$DATABASE_BACKUP_PATH" ]; then
    echo "[WARNING] No database backup path. Postgres docker will spin up with an empty database."
else
    if [[ ${DATABASE_BACKUP_PATH} == http* ]]; then
        curl ${DATABASE_BACKUP_PATH} > ./dev-configs/database_backup.gz
    else
        mv ${DATABASE_BACKUP_PATH} ./dev-configs/database_backup.gz
    fi
fi

# Preparing dev config for building docker image
mkdir ./dev-configs/${PHP_DIRECTORY}
cp ../${PHP_DIRECTORY}/Gemfile ./dev-configs/${PHP_DIRECTORY}/Gemfile
cp ../${PHP_DIRECTORY}/Gemfile.lock ./dev-configs/${PHP_DIRECTORY}/Gemfile.lock
cp ../${PHP_DIRECTORY}/.ruby-gemset ./dev-configs/${PHP_DIRECTORY}/.ruby-gemset
cp ../${PHP_DIRECTORY}/.ruby-version ./dev-configs/${PHP_DIRECTORY}/.ruby-version

mkdir ./dev-configs/${RAILS_DIRECTORY}
cp ../${RAILS_DIRECTORY}/Gemfile ./dev-configs/${RAILS_DIRECTORY}/Gemfile
cp ../${RAILS_DIRECTORY}/Gemfile.lock ./dev-configs/${RAILS_DIRECTORY}/Gemfile.lock
cp ../${RAILS_DIRECTORY}/.ruby-gemset ./dev-configs/${RAILS_DIRECTORY}/.ruby-gemset
cp ../${RAILS_DIRECTORY}/.ruby-version ./dev-configs/${RAILS_DIRECTORY}/.ruby-version

# Build development docker images
docker-compose build

# Remove vendor folder if exist
if [ -d "../${PHP_DIRECTORY}/vendor" ]; then
    rm -rf ../${PHP_DIRECTORY}/vendor
fi
# Install composer packages on development
docker-compose run development composer install

# Clean up docker: all stopped containers, all networks not used by at least 1 container, all dangling images and build caches.
docker system prune --force

# Clean up temporary files
if [ -d "./dev-configs/${PHP_DIRECTORY}" ]; then
    rm -rf ./dev-configs/${PHP_DIRECTORY}
fi

if [ -d "./dev-configs/${RAILS_DIRECTORY}" ]; then
    rm -rf ./dev-configs/${RAILS_DIRECTORY}
fi

# Set execute bit for ./dev-configs/db_init.sh
chmod +x ./dev-configs/db_init.sh

# Runs development dockers
if [ -z "$DATABASE_BACKUP_PATH" ]; then
    docker-compose -f docker-compose.yaml up --detach
else
    docker-compose -f docker-compose.yaml -f docker-compose.restoredb.yaml up --detach
fi