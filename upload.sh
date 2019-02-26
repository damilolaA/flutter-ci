#!/bin/sh

suffix=${CIRCLE_BRANCH}_$(date -d "today" +"%Y%m%d%H%M")
cp ./build/app/outputs/apk/release/app-release.apk ./app_name$suffix.apk