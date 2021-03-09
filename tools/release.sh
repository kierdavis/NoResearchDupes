#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -z "${1:-}" ]]; then
  echo >&2 "usage: $0 <version>"
  exit 1
fi

name=NoResearchDupes
version="$1"
root="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
output="$root/release/$name-$version.zip"

# Sanity check.
if ! git show "v$version:$name.txt" | grep -qE "AddOnVersion: $version\b"; then
  echo >&2 "$name.txt AddOnVersion is wrong, refusing to release."
  exit 1
fi

cd "$root"
mkdir -p "$root/release"
git archive \
  --format=zip \
  --prefix="$name/" \
  --output="$output" \
  "v$version" \
  "$name.txt" \
  "LICENSE.txt" \
  $(find . -name '*.lua')

echo >&2 "Wrote $output"
