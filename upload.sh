#!/usr/bin/env bash

set -eu pipefail

# suffix=${CIRCLE_BRANCH}_$(date -d "today" +"%Y%m%d%H%M")
suffix=$(date -d "today" +"%Y%m%d%H%M")

echo "$suffix";
echo "branch ${CIRCLE_BRANCH}"

EMAIL=adiodamilolo@yahoo.com
USER_AUTH=damilolaA
RELEASE_REPO=flutter-ci
VERSION_KEY=damo
REPO_SLUG=
COMMIT="New app release"

# cp ./build/app/outputs/apk/release/app-release.apk ./app_name$suffix.apk

# create a new directory that will contain our generated apk
mkdir $HOME/buildApk/
# copy generated apk from build folder to the folder just created
cp -a ./build/app/outputs/apk/release/app-release.apk $HOME/buildApk/
printf "Moved apks\n"
ls -a $HOME/buildApk

# go to home and setup git
echo "Clone Git"
cd $HOME
git config --global user.email "$EMAIL"
git config --global user.name "$USER_AUTH CI"
# clone the repository in the buildApk folder
git clone --quiet --branch=develop  https://$USER_AUTH:$GITHUB_API_KEY@github.com/$USER_AUTH/$RELEASE_REPO.git  develop > /dev/null
# create version file
echo "Create Version File"
cd develop
echo "$VERSION_KEY v$suffix" > "$VERSION_KEY.txt"


echo "Push Version File"
git remote rm origin
git remote add origin https://$USER_AUTH:$GITHUB_API_KEY@github.com/$USER_AUTH/$RELEASE_REPO.git
git add -f .
git commit -m "Circle build $suffix pushed [skip ci]"
git push -fq origin develop > /dev/null

echo "Create New Release"
API_JSON="$(printf '{"tag_name": "v%s","target_commitish": "develop","name": "v%s","body": "Automatic Release v%s for branch %s %s","draft": false,"prerelease": false}' $suffix $suffix $suffix "\nhttps://github.com/$REPO_SLUG/commit/$COMMIT")"
# newRelease="$(curl --data "$API_JSON" https://api.github.com/repos/$RELEASE_REPO/releases?access_token=$GITHUB_API_KEY)"
# newRelease="$(curl --data  https://api.github.com/repos/$RELEASE_REPO/releases?access_token=$GITHUB_API_KEY)"

# rID="$(echo "$newRelease" | jq ".id")"
rID="1.1.0"

cd $HOME/buildApk/
# echo "Push apk to $rID"
echo "Push apk to github"
for apk in $(find *.apk -type f); do
  apkName="${apk::-4}"
  printf "Apk $apkName\n"
  # curl "https://uploads.github.com/repos/${RELEASE_REPO}/releases/${rID}/assets?access_token=${GITHUB_API_KEY}&name=${apkName}-v1.apk" --header 'Content-Type: application/zip' --upload-file $apkName.apk -X POST
  # curl "https://uploads.github.com/repos/${RELEASE_REPO}/assets?access_token=${GITHUB_API_KEY}&name=${apkName}-v1.apk" --header 'Content-Type: application/zip' --upload-file $apkName.apk -X POST

  curl \
    -X POST \
    -H "Content-Type: vnd.android.package-archive" \
    -F "file=@/$HOME/buildApk/${apkName}.apk" \
    "https://uploads.github.com/repos/${RELEASE_REPO}/releases/${rID}/assets?access_token=${GITHUB_API_KEY}&name=${apkName}-v1.apk"


done

echo -e "Done\n"