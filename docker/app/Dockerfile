FROM alpine:3.6

ADD ruby-version /ruby-version
ADD bundler-version /bundler-version

RUN apk update

# Build dependencies
RUN apk add \
  g++ \
  libffi-dev \
  # Nokogiri
  libxml2-dev libxslt-dev zlib-dev \
  make \
  postgresql-dev

# Main Ruby, + extras needed for bundler/Rails on Alpine. The weird
# version constraint allows us to share the configured Ruby version
# with stuff not using the Alpine package manager (i.e. stuff that
# doesn't understand the -rXXX suffix), though we need to make sure it
# actually resolves to a Ruby of the desired version.
RUN apk add "ruby-dev<$(cat /ruby-version)-r1000" ruby-bigdecimal ruby-io-console ruby-irb ruby-json
RUN echo 'gem: --no-document' >> /etc/gemrc

ADD bundler-version /bundler-version

RUN gem install bundler --version $(cat /bundler-version) &&\
  bundle config --global silence_root_warning 1 &&\
  bundle config --global path vendor/bundle/$(cat /ruby-version) &&\
  bundle config --global bin vendor/bundle/$(cat /ruby-version)/bin &&\
  bundle config --global build.nokogiri --use-system-libraries

WORKDIR /app
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]