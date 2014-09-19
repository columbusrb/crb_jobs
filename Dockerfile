FROM phusion/passenger-full:0.9.12
MAINTAINER Mike Danko <danko@mittdarko.com>
ENV HOME /root
ADD build/envs.conf /etc/nginx/main.d/envs.conf
ADD build/sidekiq_run /etc/service/sidekiq/run
RUN chmod +x /etc/service/sidekiq/run
COPY build/default_nginx.conf /etc/nginx/sites-enabled/default
CMD ["/sbin/my_init"]
RUN rm -f /etc/service/nginx/down
RUN mkdir -p /home/app/crb_jobs
WORKDIR /home/app/crb_jobs
ADD Gemfile /home/app/crb_jobs/
ADD Gemfile.lock /home/app/crb_jobs/
RUN chown -R app:app /home/app/crb_jobs
USER app
ENV HOME /home/app
RUN bundle install --deployment --without=test development
ADD Rakefile /home/app/crb_jobs/
ADD /config/ /home/app/crb_jobs/config/
ADD /app/assets/ /home/app/crb_jobs/app/assets/
ADD /vendor/ /home/app/crb_jobs/vendor/
USER root
ENV HOME /root
RUN chown -R app:app /home/app/crb_jobs
USER app
ENV HOME /home/app
RUN bundle exec rake assets:precompile
ADD / /home/app/crb_jobs/
USER root
ENV HOME /root
RUN chown -R app:app /home/app/crb_jobs
RUN apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*
VOLUME /home/app/crb_jobs/log/
EXPOSE 80
