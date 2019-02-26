#!/bin/bash

set -eu pipefail

suffix=${CIRCLE_BRANCH}_$(date -d "today" +"%Y%m%d%H%M")
echo "$suffix";
echo "branch ${CIRCLE_BRANCH}"
echo "appName $app_name"
cp ./build/app/outputs/apk/release/app-release.apk ./app_name$suffix.apk