FROM alpine:3.6

ENV NODE_VERSION 6.10.3-r0
ADD npm-version /npm-version

RUN apk update

# For some reason the NPM update needs to be inlined, see
# https://github.com/npm/npm/issues/15558#issuecomment-283331163.
RUN apk add nodejs=$NODE_VERSION nodejs-npm &&\
  npm install -g npm@$(cat /npm-version)

WORKDIR /app
CMD ["node_modules/.bin/webpack-dev-server"]