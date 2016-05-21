FROM ruby:2.3.0

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update &&\
  apt-get install -y \
    nodejs \
    --no-install-recommends &&\
  rm -rf /var/lib/apt/lists/*

RUN gem install bundler --version 1.12.4

RUN bundle config build.nokogiri --use-system-libraries
ENV BUNDLE_PATH /app/vendor/bundle/$RUBY_VERSION
ENV BUNDLE_BIN_PATH /app/vendor/bundle/$RUBY_VERSION

WORKDIR /app

CMD ["bundle", "exec", "rails", "server", "Puma", "-b", "0.0.0.0"]