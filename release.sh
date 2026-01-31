#!/usr/bin/env bash
set -e

# Bump version & create tag
# Docs: https://commitizen-tools.github.io/commitizen/
cz bump

# Get latest tag only
TAG=$(git describe --tags --abbrev=0)
VERSION="${TAG#v}" # strip leading "v" if present

# Update Go version in `./version.go
sed -i "s/const Version = \".*\"/const Version = \"v${VERSION}\"/" ./version.go

# Update `frontend/package.json` version
sed -i "s/\"version\": \".*\"/\"version\": \"${VERSION}\"/" frontend/package.json

git add .
git commit --amend
