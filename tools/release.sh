#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -z "${1:-}" ]]; then
  echo >&2 "usage: $0 <version>"
  exit 1
fi

name=NoResearchDupes
version="$1"
root="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"

cd "$root"
mkdir -p "$root/release"
git archive \
  --format=zip \
  --prefix="$name/" \
  --output="$root/release/$name-$version.zip" \
  "v$version" \
  "$name.txt" \
  "LICENSE.txt" \
  $(find . -name '*.lua')
