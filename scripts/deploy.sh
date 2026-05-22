#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ENV_FILE="${ENV_FILE:-.env.deploy}"
COMPOSE_FILES="-f compose.yaml -f compose.prod.yaml"
START_TIME="$(date +%s)"

cd "$ROOT_DIR"

info() {
	printf '%s %s\n' "==>" "$*"
}

fail() {
	printf '%s\n' "ERROR: $*" >&2
	exit 1
}

compose() {
	env \
		-u APP_SECRET \
		-u DATABASE_URL \
		-u DEFAULT_URI \
		-u HTTP3_PORT \
		-u HTTPS_PORT \
		-u HTTP_PORT \
		-u MYSQL_DATABASE \
		-u MYSQL_PASSWORD \
		-u MYSQL_ROOT_PASSWORD \
		-u MYSQL_USER \
		-u PRIMARY_DOMAIN \
		-u SERVER_NAME \
		docker compose --env-file "$ENV_FILE" $COMPOSE_FILES "$@"
}

elapsed() {
	NOW="$(date +%s)"
	printf '%ss' "$((NOW - START_TIME))"
}

command -v docker >/dev/null 2>&1 || fail "Docker is not installed."
docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin is not installed."
command -v gh >/dev/null 2>&1 || fail "GitHub CLI is not installed."
gh auth status >/dev/null 2>&1 || fail "GitHub CLI is not authenticated. Run: gh auth login"

[ -f "$ENV_FILE" ] || fail "Missing $ENV_FILE. Create it from .env.deploy.example and fill production secrets."
[ -f compose.yaml ] || fail "Missing compose.yaml."
[ -f compose.prod.yaml ] || fail "Missing compose.prod.yaml."

info "Validating Docker Compose config"
compose config --quiet
compose config | grep 'SERVER_NAME:' || true

if [ -d .git ]; then
	info "Syncing repository with GitHub"
	gh repo sync
else
	info "No .git directory found; skipping GitHub sync"
fi

info "Building and starting production containers"
compose up -d --build --remove-orphans

info "Container status"
compose ps

info "Recent application logs"
compose logs --tail=40 php

info "Deploy complete in $(elapsed)"
printf '%s\n' "Useful commands:"
printf '%s\n' "  docker compose --env-file $ENV_FILE $COMPOSE_FILES logs -f php"
printf '%s\n' "  docker compose --env-file $ENV_FILE $COMPOSE_FILES ps"
