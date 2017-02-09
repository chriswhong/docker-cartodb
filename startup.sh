#!/bin/bash

PORT=3000

service postgresql start
service redis-server start
service varnish start

cd /Windshaft-cartodb
node app.js production &

cd /CartoDB-SQL-API
node app.js production &

cd /cartodb
source /usr/local/rvm/scripts/rvm
bundle exec script/restore_redis
bundle exec script/resque > resque.log 2>&1 &
bundle exec rails s -p $PORT
