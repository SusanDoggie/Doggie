#!/bin/bash
set -e

if [ -n "${DOCKER_IMAGE}" ]; then
  docker pull ${DOCKER_IMAGE}
  docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "cd $TRAVIS_BUILD_DIR && ./.travis-build.sh"
  exit $?
fi

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

echo -en "travis_fold:start:install_git\\r${ANSI_CLEAR}"
apt-get update && apt-get install -y git
echo -en "travis_fold:end:install_git\\r${ANSI_CLEAR}"

cat <<"EOF" > ./.before-install-swift
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install -y fontconfig ttf-mscorefonts-installer
EOF

fi

git clone https://github.com/SusanDoggie/Package-Builder.git

while true; do echo "..."; sleep 60; done &
./Package-Builder/build-package.sh
kill %1
