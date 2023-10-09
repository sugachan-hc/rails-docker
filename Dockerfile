FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /rails-docker

WORKDIR /rails-docker

ADD Gemfile Gemfile.lock /rails-docker/

RUN gem install bundler
RUN bundle install

ADD . /rails-docker
