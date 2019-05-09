#!/bin/bash
set -e

if [ -n "${DOCKER_IMAGE}" ]; then

  git clone https://github.com/SusanDoggie/Package-Builder.git

  docker pull ${DOCKER_IMAGE}
  docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "cd $TRAVIS_BUILD_DIR && ./.travis-build.sh"
  exit $?
  
fi

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

cat <<"EOF" > ./.before-install-swift
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install -y fontconfig ttf-mscorefonts-installer
EOF

fi

while true; do echo "..."; sleep 60; done &
./Package-Builder/build-package.sh
kill %1
