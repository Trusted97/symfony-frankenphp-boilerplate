#syntax=docker/dockerfile:1

# ======================
# Base FrankenPHP lightweight
# ======================
FROM dunglas/frankenphp:1-php8.4 AS frankenphp_base

WORKDIR /app
VOLUME /app/var/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git file curl unzip; \
    install-php-extensions @composer apcu pdo pdo_mysql intl opcache zip; \
    apt-get clean

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

COPY --link frankenphp/conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link frankenphp/Caddyfile /etc/frankenphp/Caddyfile

ENTRYPOINT ["docker-entrypoint"]
HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1


# ======================
# Composer dependencies
# ======================
FROM frankenphp_base AS composer_vendor

WORKDIR /app

COPY composer.* symfony.* ./

RUN --mount=type=cache,target=/tmp/composer-cache \
    COMPOSER_CACHE_DIR=/tmp/composer-cache \
    composer install \
    --prefer-dist \
    --no-dev \
    --no-scripts \
    --no-progress \
    --no-interaction


# ======================
# Node/Yarn builder
# ======================
FROM node:26-alpine AS node_builder

WORKDIR /app

COPY --from=composer_vendor /app/vendor ./vendor

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/usr/local/share/.cache/yarn \
    yarn install --frozen-lockfile --prefer-offline --non-interactive

COPY assets ./assets
COPY webpack.config.js ./

RUN yarn run build && rm -rf node_modules


# ======================
# Development FrankenPHP
# ======================
FROM frankenphp_base AS frankenphp_dev

ENV APP_ENV=dev
ENV XDEBUG_MODE=off
ENV FRANKENPHP_WORKER_CONFIG=watch

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && install-php-extensions xdebug

COPY --link frankenphp/conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/

COPY --link --exclude=frankenphp/ . ./

CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch"]


# ======================
# Production FrankenPHP
# ======================
FROM frankenphp_base AS frankenphp_prod

ENV APP_ENV=prod

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --link frankenphp/conf.d/20-app.prod.ini $PHP_INI_DIR/app.conf.d/

# App source
COPY --link --exclude=frankenphp/ --exclude=node_modules --exclude=.git . ./

# Composer deps
COPY --from=composer_vendor /app/vendor ./vendor
COPY --from=composer_vendor /app/composer.lock ./composer.lock

# Built assets
COPY --from=node_builder /app/public/build ./public/build

# Final optimizations
RUN set -eux; \
    mkdir -p var/cache var/log var/share; \
    composer dump-autoload --classmap-authoritative --no-dev; \
    composer dump-env prod; \
    php bin/console assets:install public --no-interaction; \
    chmod +x bin/console

CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
