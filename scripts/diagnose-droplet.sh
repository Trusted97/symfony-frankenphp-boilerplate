#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ENV_FILE="${ENV_FILE:-.env.deploy}"
COMPOSE_FILES="-f compose.yaml -f compose.prod.yaml"

cd "$ROOT_DIR"

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

line() {
	printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

section() {
	printf '\n'
	line
	printf '📊 %s\n' "$*"
	line
}

ok() {
	printf '✅ %s\n' "$*"
}

warn() {
	printf '⚠️  %s\n' "$*"
}

error() {
	printf '❌ %s\n' "$*" >&2
}

info() {
	printf 'ℹ️  %s\n' "$*"
}

run() {
	DESC="$1"
	shift

	printf '\n🔹 %s\n\n' "$DESC"

	if "$@"; then
		ok "$DESC completed"
	else
		warn "$DESC failed"
	fi
}

[ -f "$ENV_FILE" ] || {
	error "Missing $ENV_FILE"
	exit 1
}

printf '\n🚀 Docker Host Diagnostic\n'
printf '📁 Root: %s\n' "$ROOT_DIR"
printf '🧾 Env:  %s\n' "$ENV_FILE"

section "Host memory"
run "Checking memory usage" free -h

section "Host disk"
run "Checking disk usage" df -h

section "Containers"
run "Listing containers" compose ps

printf '\n🎉 Diagnostics completed\n'
