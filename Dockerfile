# --- Build stage: compile gems and precompile assets ---
FROM ruby:3.3.6-slim AS builder

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y build-essential libmariadb-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=placeholder \
    bundle exec rails assets:precompile

# --- Development stage: full gem set, live code via bind mount ---
FROM ruby:3.3.6-slim AS development

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y build-essential libmariadb-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

EXPOSE 8080

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -p 8080 -b 0.0.0.0"]

# --- Production stage: lean runtime image ---
FROM ruby:3.3.6-slim AS production

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y libmariadb3 && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --system app && useradd --system --gid app app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=app:app /app .

RUN mkdir -p tmp/cache && chown app:app tmp/cache

USER app

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
