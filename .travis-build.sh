#!/bin/bash

set -e

if [ -n "${DOCKER_IMAGE}" ]; then

docker pull ${DOCKER_IMAGE}
docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "apt-get update && apt-get install -y git sudo lsb-release wget libxml2 && cd $TRAVIS_BUILD_DIR && ./.travis-build.sh"
exit $?

fi

git clone https://github.com/IBM-Swift/Package-Builder.git

if [ "$(uname)" == "Darwin" ]; then

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

echo | cat >./.swift-xcodeproj
echo | cat >./.swift-codecov

cat <<"EOF" > ./.swift-build-macOS
#!/bin/bash
set -e
for SCHEME in ${SCHEMES}; do
echo "Building scheme ${SCHEME}"
xcodebuild $XCODEBUILD_CONFIG -scheme $SCHEME
done
EOF

cat <<"EOF" > ./.swift-test-macOS
#!/bin/bash
set -e
for SCHEME in ${SCHEMES}; do
echo "Testing scheme ${SCHEME}"
xcodebuild $XCODEBUILD_CONFIG -scheme $SCHEME test -enableCodeCoverage ${ENABLE_CODECOV} -skipUnavailableActions
done
EOF

else

echo "swift build -c release" | cat >./.swift-build-linux
echo "swift test -c release" | cat >./.swift-test-linux

fi

while true; do echo "..."; sleep 60; done &
./Package-Builder/build-package.sh -projectDir $(pwd)
kill %1
