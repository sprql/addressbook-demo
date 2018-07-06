FROM ruby:2.5-alpine AS base

ENV RAILS_ENV=production \
    RACK_ENV=production

WORKDIR /srv/addressbook
ENTRYPOINT ["bin/docker_entrypoint"]

RUN apk add --update --no-cache libxml2-dev \
                                libxslt-dev \
                                postgresql-dev

# Build stage
FROM base AS build
RUN apk add --update --no-cache git \
                                build-base
ADD Gemfile Gemfile.lock ./
RUN bundle install --frozen --without development test

# App stage
FROM base
COPY --from=build /usr/local/bundle/ /usr/local/bundle/
ADD . ./
