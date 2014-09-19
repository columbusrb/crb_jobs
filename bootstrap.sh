#!/bin/bash
mkdir -p /opt/elasticsearch/data/
mkdir -p /opt/redis/data/
mkdir -p /opt/postgresql/data/
mkdir -p /opt/crb_jobs/log/

cp build/elasticsearch.yml /opt/elasticsearch/data/

docker run --name=postgres -d -v /opt/postgresql/data:/var/lib/postgresql/data postgres:9.3.5
docker run --name=elasticsearch -d -v /opt/elasticsearch/data:/data dockerfile/elasticsearch:latest /elasticsearch/bin/elasticsearch -Des.config=/data/elasticsearch.yml
docker run --name=redis -d -v /opt/redis/data:/data dockerfile/redis

export PG_IP=$(docker inspect postgres | grep IPAddres | awk -F'"' '{print $4}')

docker run -t -i --rm -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           -p 80:80 \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest \
            rake db:create db:migrate

docker run --name=rails -d -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           -p 80:80 \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest
