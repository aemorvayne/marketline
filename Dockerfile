ARG RUBY_VERSION=4.0.7
FROM ruby:${RUBY_VERSION}-slim AS build

ENV BUNDLE_DEPLOYMENT=true BUNDLE_WITHOUT=development:test BUNDLE_PATH=/usr/local/bundle
WORKDIR /app

RUN apt-get update && apt-get install --no-install-recommends -y build-essential && rm -rf /var/lib/apt/lists/*
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM ruby:${RUBY_VERSION}-slim

ENV RACK_ENV=production BUNDLE_DEPLOYMENT=true BUNDLE_WITHOUT=development:test BUNDLE_PATH=/usr/local/bundle
WORKDIR /app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY Gemfile Gemfile.lock app.rb config.ru ./
COPY config ./config
COPY lib ./lib
COPY data ./data
COPY views ./views
COPY public ./public

RUN groupadd --system app && useradd --system --gid app --no-create-home app
USER app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
