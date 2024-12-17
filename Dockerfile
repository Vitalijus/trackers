
# Use the official Ruby image with version 3.3.0
FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  build-essential \
  curl

# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

# Install the specified Ruby version using rbenv
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"
RUN rbenv install 3.3.0 && rbenv global 3.3.0

# Set the working directory
WORKDIR /trackers

# Copy the Gemfile and Gemfile.lock
COPY Gemfile /trackers/Gemfile
COPY Gemfile.lock /trackers/Gemfile.lock

# Install Gems dependencies
RUN gem install bundler && bundle install

# Expose the port the app runs on
EXPOSE 3000

# Command to run the rails server
CMD ["rails", "server", "-b", "0.0.0.0"]

# Add a script to be executed every time the container starts. Fixes a glitch with the pids
# directory by removing the server.pid file on execute.
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
