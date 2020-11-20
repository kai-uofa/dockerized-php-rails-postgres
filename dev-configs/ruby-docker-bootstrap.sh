#!/bin/bash

source /usr/share/rvm/scripts/rvm || source /etc/profile.d/rvm.sh

rvm install $1

rvm use --default $1

rvm cleanup all
gem install bundler

cd /var/www/html
bundle install

cd /$2
bundle install