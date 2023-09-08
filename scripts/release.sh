#!/bin/bash

[ $# -eq 1 ] || exit 1

echo "start gitflow release"

git checkout main

git merge dev

echo "update artifacts"

echo "release version started"

git add .

git commit -m "release new plugin version: $1"

git push

echo "create tag"

git tag $1

git push origin $1
