#!/bin/bash

# The travis_retry function  is not available is subshells/commands. See this tweet for details https://twitter.com/travisci/status/499195739353153539?s=20
travis_retry() {
  local result=0
  local count=1
  while [[ "${count}" -le 3 ]]; do
    [[ "${result}" -ne 0 ]] && {
      echo -e "\\n${ANSI_RED}The command \"${*}\" failed. Retrying, ${count} of 3.${ANSI_RESET}\\n" >&2
    }
    # run the command in a way that doesn't disable setting `errexit`
    "${@}"
    result="${?}"
    if [[ $result -eq 0 ]]; then break; fi
    count="$((count + 1))"
    sleep 1
  done

  [[ "${count}" -gt 3 ]] && {
    echo -e "\\n${ANSI_RED}The command \"${*}\" failed 3 times.${ANSI_RESET}\\n" >&2
  }

  return "${result}"
}

# The -e flag makes the build fail if there are any errors
# The -v flag makes the shell print all lines before executing them
set -ev

# Set environment variables
export ALGOLIA_API_KEY=64ecbeea31e6025386637d89711e31f3
export ALGOLIA_APP_ID=EWKZLLNQ9L
export BRANCH_VERSION_CONFIG=2.6=2.6,2.5=2.5,2.4=2.4,2.3=2.3,2.2=2.2,2.1=2.1,2.0.3=2.0,1.7=1.7
export GCP_CLUSTER_ID=production-app-cluster
export GCP_PROJECT_ID=production-apps-210001
export GCP_ZONE=us-west1-b
export LATEST_VERSION=2.6
export PRODUCT_NAME="Portworx Enterprise"
export PRODUCT_INDEX_NAME=PX-Enterprise
export VERSIONS_BASE_URL=docs.portworx.com
#Docker builds cannot use uppercase characters in the image name
export LOWER_CASE_BRANCH=$(echo -n $TRAVIS_BRANCH | awk '{print tolower($0)}')
export BUILDER_IMAGE="pxdocs:$TRAVIS_COMMIT"
export SEARCH_INDEX_IMAGE="pxdocs-indexer:$TRAVIS_COMMIT"
export DEPLOYMENT_IMAGE="gcr.io/$GCP_PROJECT_ID/pxdocs-$LOWER_CASE_BRANCH:$TRAVIS_COMMIT"
export VERSIONS_CURRENT=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-current-branch-version)
export VERSIONS_ALL=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-all-versions)
export VERSIONS_TAG=$(echo -n "$VERSIONS_CURRENT" | sed 's/\./-/g')
export ALGOLIA_INDEX_NAME="${PRODUCT_INDEX_NAME}-${VERSIONS_TAG}"
export OTHER_PRODUCT_NAMES_AND_INDICES=PX-Backup=PX-Backup-1-1
export PRODUCT_NAMES_AND_INDICES="${PRODUCT_NAME}=${PRODUCT_INDEX_NAME}-${TRAVIS_BRANCH/./-},${OTHER_PRODUCT_NAMES_AND_INDICES}"
if [ "${VERSIONS_BASE_URL}" '==' "docs.portworx.com" ]; then export NGINX_REDIRECTS_FILE=px-enterprise-redirects.conf ; fi
if [ "${VERSIONS_BASE_URL}" '==' "backup.docs.portworx.com" ]; then export NGINX_REDIRECTS_FILE=px-backup-redirects.conf ; fi
# build images
travis_retry make image
# publish site -> public
make publish-docker
# build the deployment image
travis_retry make deployment-image
travis_retry make check-links
# if this is a pull request then we don't want to update algolia or deploy
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then exit 0; fi
# this checks if the current branch is present in the BRANCH_VERSION_CONFIG variable if exists if not
if [ "${TRAVIS_PULL_REQUEST}" == "false" ] && [ "$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh should-build-current-branch)" != "yes" ]; then exit 0; fi
# update the Algolia index
travis_retry make search-index-image
travis_retry make search-index-docker
# connect the GCLOUD_SERVICE_ACCOUNT_TOKEN, GCP_PROJECT_ID, GCP_ZONE and GCP_CLUSTER_ID vars -> gcloud and kubectl
bash themes/pxdocs-tooling/deploy/scripts/ci_connect.sh
# push the image to gcr
echo "Pushing image $DEPLOYMENT_IMAGE"
gcloud docker -- push $DEPLOYMENT_IMAGE
echo "Deploying image $DEPLOYMENT_IMAGE"
cat themes/pxdocs-tooling/deploy/manifests/deployment.yaml | envsubst
cat themes/pxdocs-tooling/deploy/manifests/deployment.yaml | envsubst | kubectl apply -f -
cat themes/pxdocs-tooling/deploy/manifests/service-template.yaml | envsubst
cat themes/pxdocs-tooling/deploy/manifests/service-template.yaml | envsubst | kubectl apply -f -
