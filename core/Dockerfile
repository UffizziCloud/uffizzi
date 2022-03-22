FROM ruby:3.0.2-alpine3.14

RUN apk update && apk upgrade && apk add bash curl-dev ruby-dev build-base git \
                                 curl ruby-json openssl postgresql-dev postgresql-client tzdata

RUN mkdir -p /gem
WORKDIR /gem

ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

COPY lib/uffizzi_core/version.rb /gem/lib/uffizzi_core/
COPY uffizzi_core.gemspec /gem/
COPY Gemfile* /gem/
RUN bundle install --jobs 4

COPY . /gem
