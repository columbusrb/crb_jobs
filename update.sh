#!/bin/bash

export PG_IP=$(docker inspect postgres | grep IPAddres | awk -F'"' '{print $4}')

docker run -t -i --rm -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
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
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest
