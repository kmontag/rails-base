FROM ruby:2.3.0

RUN apt-get update &&\
  apt-get install -y \
    mysql-client \
    nodejs \
    --no-install-recommends &&\
  rm -rf /var/lib/apt/lists/*

RUN gem install bundler --version 1.11.2 &&\
  bundle config path vendor/bundle/$RUBY_VERSION &&\
  bundle config bin vendor/bundle/$RUBY_VERSION/bin &&\
  bundle config build.nokogiri --use-system-libraries

WORKDIR /app
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]