# Dockerfile
FROM ruby:3.3.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /trackers
COPY Gemfile /trackers/Gemfile
COPY Gemfile.lock /trackers/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts. Fixes a glitch with the pids directory by removing the server.pid file on execute.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Runs a rails server command to start the rails server, pointing it to local host.
CMD ["rails", "server", "-b", "0.0.0.0"]
