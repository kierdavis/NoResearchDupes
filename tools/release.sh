#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -z "${1:-}" ]]; then
  echo >&2 "usage: $0 <version>"
  exit 1
fi
version=$1

name=NoResearchDupes

mkdir -p release
git archive --format=zip --prefix="$name/" --output="release/$name-$version.zip" "v$version" NoResearchDupes.txt *.lua
