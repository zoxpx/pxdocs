#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE=${IMAGE:=px-docs-spike:latest}
EXTRA_HUGO_ARGS=""

if [ "$1" == "server" ]; then
  EXTRA_HUGO_ARGS="--bind=0.0.0.0"
fi

if [ -n "$BUILD" ]; then
  docker build -t $IMAGE .
fi

docker run -ti --rm \
  --name px-docs-spike \
  -p 1313:1313 \
  -v "$DIR:/px-docs-spike" \
  $IMAGE "$@" "$EXTRA_HUGO_ARGS"