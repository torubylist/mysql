#!/bin/bash
set -xeou pipefail

GOPATH=$(go env GOPATH)
REPO_ROOT=$GOPATH/src/github.com/kubedb/mysql

source "$REPO_ROOT/hack/libbuild/common/lib.sh"
source "$REPO_ROOT/hack/libbuild/common/kubedb_image.sh"

DOCKER_REGISTRY=${DOCKER_REGISTRY:-kubedb}

IMG=mysql-tools
SUFFIX=v1

DB_VERSION=8.0
TAG="$DB_VERSION-$SUFFIX"

ALT_VERSION=8
ALT_TAG="$ALT_VERSION-$SUFFIX"

OSM_VER=${OSM_VER:-0.7.1}

DIST=$REPO_ROOT/dist
mkdir -p $DIST

build() {
  pushd "$REPO_ROOT/hack/docker/mysql-tools/$DB_VERSION"

  # Download osm
  wget https://cdn.appscode.com/binaries/osm/${OSM_VER}/osm-alpine-amd64
  chmod +x osm-alpine-amd64
  mv osm-alpine-amd64 osm

  local cmd="docker build -t $DOCKER_REGISTRY/$IMG:$TAG ."
  echo $cmd; $cmd

  rm osm
  popd
}

docker_push() {
  local cmd="docker tag $DOCKER_REGISTRY/$IMG:$TAG $DOCKER_REGISTRY/$IMG:$ALT_TAG"
  echo $cmd; $cmd
  cmd="docker push $DOCKER_REGISTRY/$IMG:$ALT_TAG"
  echo $cmd; $cmd

  hub_canary
}

binary_repo $@
