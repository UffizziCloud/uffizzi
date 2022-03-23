FROM ruby:2.7.5-slim

ARG RAILS_ROOT=/app
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN apt-get update \
  && apt-get install -qq -y --no-install-recommends \
  vim-tiny \
  python2-dev \
  libpq-dev \
  build-essential \
  curl \
  less \
  tzdata \
  git \
  postgresql-client \
  bash \
  screen \
  shared-mime-info \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler:2.3.9

COPY Gemfile Gemfile.lock $RAILS_ROOT/
COPY core/lib/uffizzi_core/version.rb $RAILS_ROOT/core/lib/uffizzi_core/version.rb
COPY core/uffizzi_core.gemspec $RAILS_ROOT/core/uffizzi_core.gemspec
COPY core/Gemfile* $RAILS_ROOT/core

RUN bundle install --jobs 5

COPY . $RAILS_ROOT

ENV PATH=$RAILS_ROOT/bin:${PATH}

EXPOSE 7000

CMD /bin/bash -c "bundle exec rails db:create db:migrate && bundle exec puma -C config/puma.rb"
