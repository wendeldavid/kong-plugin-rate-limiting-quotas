#!/bin/bash

[ $# -eq 1 ] || exit 1

echo "start gitflow release"

git checkout main

git merge dev

echo "update artifacts"

sed -i "s|\${TAG}|$1|g" kong-plugin-rate-limiting-quotas-TAG-1.rockspec

mv kong-plugin-rate-limiting-quotas-TAG-1.rockspec kong-plugin-rate-limiting-quotas-$1-1.rockspec

echo "release version started"

git add .

git commit -m "release new plugin version: $1"

git push

echo "create tag"

git tag $1

git push origin $1
