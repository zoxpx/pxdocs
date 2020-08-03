VERSION=""
URL=""
PROTO="https://"
PROTO_AND_VERSION=""

if [ -z "$TRAVIS_BRANCH" ] || [ -z "$BRANCH_VERSION_CONFIG" ] || [ -z "$VERSIONS_BASE_URL" ]
then
  echo "One of the following environment variables is not defined: \$TRAVIS_BRANCH, \$BRANCH_VERSION_CONFIG."
else
  if [[ $BRANCH_VERSION_CONFIG == *$TRAVIS_BRANCH* ]]
  then
    echo "\$TRAVIS_BRANCH = $TRAVIS_BRANCH is in \$BRANCH_VERSION_CONFIG = $BRANCH_VERSION_CONFIG"
    URL=$VERSIONS_BASE_URL
    echo "\$LATEST_VERSION is $LATEST_VERSION"
    if [[ "$LATEST_VERSION" == "$TRAVIS_BRANCH" ]]
    then
      PROTO_AND_VERSION="$PROTO"
    else
      PROTO_AND_VERSION="$PROTO$TRAVIS_BRANCH."
    fi
  else
    echo "\$TRAVIS_BRANCH = $TRAVIS_BRANCH is not in \$BRANCH_VERSION_CONFIG = $BRANCH_VERSION_CONFIG"
    URL=$VERSIONS_BASE_URL
    PROTO_AND_VERSION="$PROTO"
  fi
fi

echo "\$PRODUCT_URL is $PROTO_AND_VERSION$URL"
export PRODUCT_URL=$PROTO_AND_VERSION$URL
