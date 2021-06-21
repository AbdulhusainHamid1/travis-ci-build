#!/bin/bash

: '
Copyright (C) 2019,2021 IBM Corporation
Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    Rafael Sene <rpsene@br.ibm.com> - Initial implementation.
'

#Trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "bye!"
}

function check_dependencies() {

	if command -v "podman" &> /dev/null; then
	   echo "Setting podman as container runtime..."
	   export CONTAINER_RUNTIME="podman"
	elif command -v "docker" &> /dev/null; then
	   echo "Setting docker as container runtime..."
	   export CONTAINER_RUNTIME="docker"
	else
	   echo "WARNING: installing Docker"
	   git clone https://github.com/Unicamp-OpenPower/docker.git
	   cd ./docker
	   ./install_docker.sh
	   export CONTAINER_RUNTIME="docker"
	fi
}

function pull-travis-build {
    "$CONTAINER_RUNTIME" pull quay.io/rpsene/travis-build:latest
}

function start-travis-build {
    #SUFIX=$(date +%s | sha256sum | base64 | head -c 6 ; echo)
    SUFIX=$(openssl rand -hex 6)
    "$CONTAINER_RUNTIME" run --hostname=travis-build --name travis-build-$SUFIX --restart=always \
    -d -p $1:4000 quay.io/rpsene/travis-build:latest
}

PORTS=( 4000 4001 4002 4003 )

check_dependencies
pull-travis-build
for port in ${PORTS[*]}; do
  start-travis-build $port
done
