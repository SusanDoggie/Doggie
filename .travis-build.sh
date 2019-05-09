#!/bin/bash
set -e

if [ -n "${DOCKER_IMAGE}" ]; then
  docker pull ${DOCKER_IMAGE}
  docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "cd $TRAVIS_BUILD_DIR && ./.travis-build.sh"
  exit $?
fi

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
cat <<"EOF" > ./.before-install-swift
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y git sudo lsb-release wget libxml2 zlib1g-dev fontconfig
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install -y ttf-mscorefonts-installer
EOF
fi

git clone https://github.com/SusanDoggie/Package-Builder.git

while true; do echo "..."; sleep 60; done &
./Package-Builder/build-package.sh
kill %1
