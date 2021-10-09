#!/bin/sh

#set -o errexit
#set -o pipefail
# set -o xtrace

[ "${BASH_DEBUG:-false}" = "true" ] && set -x

# Constants
MODULE="$(basename "$0")"

LARAVEL_TEMP_DIR=/tmp/laravel
LARAVEL_TEMP_FILENAME=laravel.zip
LARAVEL_VERSION=8.x
LARAVEL_URL="https://github.com/laravel/laravel/archive/refs/heads/${LARAVEL_VERSION}.zip"
install_laravel() {
  mkdir "${LARAVEL_TEMP_DIR}" &&
  curl -sL -o "${LARAVEL_TEMP_DIR}/${LARAVEL_TEMP_FILENAME}" "${LARAVEL_URL}" &&
  unzip -d "${LARAVEL_TEMP_DIR}" "${LARAVEL_TEMP_DIR}/${LARAVEL_TEMP_FILENAME}" || exit 1
  mv -t "/app" "${LARAVEL_TEMP_DIR}/laravel-${LARAVEL_VERSION}/".* "${LARAVEL_TEMP_DIR}/laravel-${LARAVEL_VERSION}/"*
  rm -rf "${LARAVEL_TEMP_DIR}"
}

# shellcheck disable=SC2034
{
  # Color Palette
  RESET='\033[0m'
  BOLD='\033[1m'

  ## Foreground
  BLACK='\033[38;5;0m'
  RED='\033[38;5;1m'
  GREEN='\033[38;5;2m'
  YELLOW='\033[38;5;3m'
  BLUE='\033[38;5;4m'
  MAGENTA='\033[38;5;5m'
  CYAN='\033[38;5;6m'
  WHITE='\033[38;5;7m'
}

stderr_print() {
  printf "%b\\n" "${*}" >&2
}

log() {
  stderr_print "${NAMI_DEBUG:+${CYAN}${MODULE:-} ${MAGENTA}$(date "+%T.%2N ")}${RESET}${*}"
}

success() {
  log "${GREEN}SUCCESS${RESET} ==> ${*}"
}

error() {
  log "${RED}ERROR  ${RESET} ==> ${*}"
}

warn() {
  log "${YELLOW}WARN   ${RESET} ==> ${*}"
}

if [ "${1}" = "php" ] && [ "$2" = "artisan" ] && [ "$3" = "serve" ]; then
  if [ ! -d /app/app ]; then
    log "Creating laravel application"
    install_laravel || {
      error "Cannot install Laravel (${LARAVEL_VERSION})"
      exit 1
    }
    log "Regenerating APP_KEY"
    php artisan key:generate --ansi
  fi

  log "Installing/Updating Laravel dependencies (composer)"
  if [ ! -d /app/vendor ]; then
    composer install
    log "Dependencies installed"
  elif [ "${SKIP_COMPOSER_UPDATE:-false}" != "true" ]; then
    composer update
    log "Dependencies updated"
  fi

fi

exec "$@"
