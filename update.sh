#!/bin/bash

export ES_IP=$(docker inspect elasticsearch | grep IPAddres | awk -F'"' '{print $4}')
export REDIS_IP=$(docker inspect redis | grep IPAddres | awk -F'"' '{print $4}')
export PG_IP=$(docker inspect postgres | grep IPAddres | awk -F'"' '{print $4}')

docker run -t -i --rm -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e ELASTICSEARCH_URL=http://$ES_IP:9200 \
           -e REDIS_URL=redis://$REDIS_IP \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest \
            rake db:create db:migrate

docker pull columbusrb/crb_jobs:latest
docker stop rails
docker rm rails

docker run --name=rails -d -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           -p 80:80 \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e ELASTICSEARCH_URL=http://$ES_IP:9200 \
           -e REDIS_URL=redis://$REDIS_IP \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest
