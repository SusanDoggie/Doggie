#!/bin/bash
set -e

if [ -n "${DOCKER_IMAGE}" ]; then

docker pull ${DOCKER_IMAGE}
docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "apt-get update && apt-get install -y git sudo lsb-release wget libxml2 && cd $TRAVIS_BUILD_DIR && ./.travis-build.sh"
exit $?

fi

git clone https://github.com/IBM-Swift/Package-Builder.git

function travis_start () {
  export TRAVIS_CURRENT_SECTION=$1
  travis_fold start ${TRAVIS_CURRENT_SECTION}
  travis_time_start
}

function travis_end () {
  travis_time_finish
  travis_fold end ${TRAVIS_CURRENT_SECTION}
}

if [ "$(uname)" == "Darwin" -a -n "${USE_XCODEBUILD}" ]; then

if [ -z "${SDK}" ]; then
export SDK=macosx
fi

if [ -n "${CODECOV_ELIGIBLE}" ]; then
export ENABLE_CODECOV=YES
else
export ENABLE_CODECOV=NO
fi

export XCODEBUILD_CONFIG="-project Doggie.xcodeproj -configuration Release -sdk ${SDK}"
export SCHEMES=$(xcodebuild -list -project Doggie.xcodeproj | grep --after-context=-1 '^\s*Schemes:' | tail -n +2 | xargs)

echo "available scheme: ${SCHEMES}"
echo

travis_start "xctool_install"
brew install xctool
travis_end

cat <<"EOF" > ./.swift-build-macOS
#!/bin/bash
set -e
for SCHEME in ${SCHEMES}; do
echo "Building scheme ${SCHEME}"
xctool $XCODEBUILD_CONFIG -scheme $SCHEME
done
EOF

cat <<"EOF" > ./.swift-test-macOS
#!/bin/bash
set -e
for SCHEME in ${SCHEMES}; do
  echo "Testing scheme ${SCHEME}"
  xctool $XCODEBUILD_CONFIG -scheme $SCHEME test -enableCodeCoverage ${ENABLE_CODECOV} -skipUnavailableActions
done
EOF

cat <<"EOF" > ./.swift-codecov
#!/bin/bash

(( MODULE_COUNT = 0 ))
BASH_BASE="bash <(curl -s https://codecov.io/bash)"
for module in $(ls -F Sources/ 2>/dev/null | grep '/$'); do   # get only directories in "Sources/"
module=${module%/}                                        # remove trailing slash
BASH_CMD="$BASH_BASE -J '^${module}\$' -F '${module}'"
(( MODULE_COUNT++ ))

echo ">> Running: $BASH_CMD"
eval "$BASH_CMD"
if [[ $? != 0 ]]; then
  echo ">> Error running: $BASH_CMD"
  exit 1
fi
done

if (( MODULE_COUNT == 0 )); then
  echo ">> Running: $BASH_BASE"
  eval "$BASH_BASE"
  if [[ $? != 0 ]]; then
    echo ">> Error running: $BASH_BASE"
    exit 1
  fi
fi

EOF

else

echo "swift build -c release" | cat >./.swift-build-macOS
echo "swift test -c release" | cat >./.swift-test-macOS
echo "swift build -c release" | cat >./.swift-build-linux
echo "swift test -c release" | cat >./.swift-test-linux

fi

while true; do echo "..."; sleep 60; done &
./Package-Builder/build-package.sh -projectDir $(pwd)
kill %1
