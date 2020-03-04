#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "$0")"/common.sh

sha256() {
  cat "${ROOT}"/dependency/sha256
}

uri() {
  cat "${ROOT}"/dependency/uri
}

version() {
  cat "${ROOT}"/dependency/version
}

# shellcheck disable=SC1090
[ -f "${ROOT}"/source/scripts/update-dependency.sh ] && source "${ROOT}"/source/scripts/update-dependency.sh


printf "➜ Building Dependency Updater\n"
GO111MODULE=on go get -ldflags='-s -w' github.com/paketoio/libpak/cmd/dependency

printf "➜ Updating Dependency\n"
dependency \
  --buildpack-toml "${ROOT}"/source/buildpack.toml \
  --name "${DEPENDENCY}" \
  --version-pattern "${VERSION_PATTERN}" \
  --version "$(version)" \
  --uri "$(uri)" \
  --sha256 "$(sha256)"

cd "${ROOT}"/source

git add buildpack.toml
git checkout -- .

git \
  -c user.name='Paketo Robot' \
  -c user.email='robot@paketo.io' \
  commit \
  --signoff \
  --message "Dependency Upgrade: ${DEPENDENCY} $(version)"