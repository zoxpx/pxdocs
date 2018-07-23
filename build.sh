#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE=${IMAGE:=px-docs-spike:latest}
EXTRA_HUGO_ARGS=""

docker rm -f px-docs-spike || true
docker build -t $IMAGE .
docker run \
  --name px-docs-spike \
  -e ALGOLIA_APP_ID \
  -e ALGOLIA_API_KEY \
  -e ALGOLIA_INDEX_NAME \
  -e VERSIONS_ALL \
  -e VERSIONS_BASE_URL \
  -e VERSIONS_CURRENT \
 $IMAGE -v --debug --gc --ignoreCache --cleanDestinationDir
rm -rf public
docker cp px-docs-spike:/px-docs-spike/public public
docker rm -f px-docs-spike