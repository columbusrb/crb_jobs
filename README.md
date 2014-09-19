## Ideas

* Delete Candidate from unsubscribe
* Markdown descriptions
* Allow closing of jobs
* Fine-grained search

## Deploying with Docker

Run bootstrap.sh on the machine that has docker installed or do all the stuff below.

1. Have a box that has docker available
2. Make some data directories for persistence:

mkdir -p /opt/elasticsearch/data/
mkdir -p /opt/redis/data/
mkdir -p /opt/postgresql/data/
mkdir -p /opt/crb_jobs/log/

3. Copy build/elasticsearch.yml to the docker hosts' /opt/elasticsearch/data/

4. Start the supporting containers
docker run --name=postgres -d -v /opt/postgresql/data:/var/lib/postgresql/data postgres:9.3.5
docker run --name=elasticsearch -d -v /opt/elasticsearch/data:/data dockerfile/elasticsearch:latest /elasticsearch/bin/elasticsearch -Des.config=/data/elasticsearch.yml
docker run --name=redis -d -v /opt/redis/data:/data dockerfile/redis

5. Set some environmental variables:
```
export PG_IP=$(docker inspect postgres | grep IPAddres | awk -F'"' '{print $4}')
```

6. If it's your first start, you'll need to create the db and migrate.

```
docker run -t -i --rm -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest \
            rake db:create db:migrate
```


7. Then start the rails container

```
docker run --name=rails -d -v /opt/crb_jobs/log:/home/app/crb_jobs/log \
           -p 80:80 \
           --link postgres:postgres \
           --link redis:redis \
           --link elasticsearch:elasticsearch \
           -e RAILS_ENV=production \
           -e DATABASE_URL=postgres://postgres@$PG_IP:5432/crb_jobs_production \
            columbusrb/crb_jobs:latest
```

## Migrations moving forward and such. 

Run update.sh on the server or just do the stuff below:

Just like you did before. Run the migrations first, pull the new container, stop the old one, then start the new one. 

```
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

```


