#!/bin/bash

# Usage:
#   chmod +x ./dev_bootstrap.sh
#   ./dev_bootstrap.sh $RAIL_GIT_URL $API_GIT_URL $DATABASE_BACKUP_PATH $RUBY_VERSION $RUBY_RAIL_GEMSET $RUBY_API_GEMSET

# RAIL_GIT_URL=$1
# API_GIT_URL=$2
# DATABASE_BACKUP_PATH=$3

# RUBY_VERSION=$4
# RUBY_RAIL_GEMSET=$5
# RUBY_API_GEMSET=$6

RAILS_DIRECTORY='rails'
PHP_DIRECTORY='php-api'
POSTGRES_DIRECTORY='postgres-data'

# Create default .env file for docker-compose
echo "RUBY_VERSION=${RUBY_VERSION}" > ./.env
echo "RAILS_DIRECTORY=${RAILS_DIRECTORY}" >> ./.env
echo "PHP_DIRECTORY=${PHP_DIRECTORY}" >> ./.env
echo "POSTGRES_DIRECTORY=${POSTGRES_DIRECTORY}" >> ./.env

# # Clone rails
# git clone ${RAIL_GIT_URL} ../${RAILS_DIRECTORY}
# # Update rails configurations
# echo ${RUBY_VERSION} > ../${RAILS_DIRECTORY}/.ruby-version
# echo ${RUBY_RAIL_GEMSET} > ../${RAILS_DIRECTORY}/.ruby-gemset
# cp ./dev-configs/database.yml.docker ../${RAILS_DIRECTORY}/config/database.yml

# # Clone api
# git clone ${API_GIT_URL} ../${PHP_DIRECTORY}
# # Update api configurations
# echo ${RUBY_VERSION} > ../${PHP_DIRECTORY}/.ruby-version
# echo ${RUBY_API_GEMSET} > ../${PHP_DIRECTORY}/.ruby-gemset
# cp ./dev-configs/config.php.docker ../${PHP_DIRECTORY}/config.php

# # Download database backup
# if [[ ${DATABASE_BACKUP_PATH} == http* ]] ;
# then
#     curl ${DATABASE_BACKUP_PATH} > ./dev-configs/database_backup.gz
# else
#     mv ${DATABASE_BACKUP_PATH} ./dev-configs/database_backup.gz
# fi

# # Preparing dev config for building docker image
# mkdir ./dev-configs/${PHP_DIRECTORY}
# cp ../${PHP_DIRECTORY}/Gemfile ./dev-configs/${PHP_DIRECTORY}/Gemfile
# cp ../${PHP_DIRECTORY}/Gemfile.lock ./dev-configs/${PHP_DIRECTORY}/Gemfile.lock
# cp ../${PHP_DIRECTORY}/.ruby-gemset ./dev-configs/${PHP_DIRECTORY}/.ruby-gemset
# cp ../${PHP_DIRECTORY}/.ruby-version ./dev-configs/${PHP_DIRECTORY}/.ruby-version

# mkdir ./dev-configs/${RAILS_DIRECTORY}
# cp ../${RAILS_DIRECTORY}/Gemfile ./dev-configs/${RAILS_DIRECTORY}/Gemfile
# cp ../${RAILS_DIRECTORY}/Gemfile.lock ./dev-configs/${RAILS_DIRECTORY}/Gemfile.lock
# cp ../${RAILS_DIRECTORY}/.ruby-gemset ./dev-configs/${RAILS_DIRECTORY}/.ruby-gemset
# cp ../${RAILS_DIRECTORY}/.ruby-version ./dev-configs/${RAILS_DIRECTORY}/.ruby-version

# # Build development docker images
# docker-compose build

# # Remove vendor folder if exist
# if [ -d "../${PHP_DIRECTORY}/vendor" ]; then
#     rm -rf ../${PHP_DIRECTORY}/vendor
# fi
# # Install composer packages on development
# docker-compose run development composer install

# # Clean up docker: all stopped containers, all networks not used by at least 1 container, all dangling images and build caches.
# docker system prune

# # Clean up temporary files
# if [ -d "./dev-configs/${PHP_DIRECTORY}" ]; then
#     rm -rf ./dev-configs/${PHP_DIRECTORY}
# fi

# if [ -d "./dev-configs/${RAILS_DIRECTORY}" ]; then
#     rm -rf ./dev-configs/${RAILS_DIRECTORY}
# fi

# # Set execute bit for ./dev-configs/db_init.sh
# chmod +x ./dev-configs/db_init.sh

# Runs development dockers
# docker-compose up --detach
docker-compose up