#!/usr/bin/env bash

gitlab=${1}
repo=${2}
branch=${3}

rm -rf "/tmp/${repo}"
git clone "${gitlab}/${repo}.git" "/tmp/${repo}"
pushd /tmp/${repo}
git checkout ${branch}
popd
