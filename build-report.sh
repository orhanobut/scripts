#!/bin/bash

rm -R app/build/report/current/
rm -R app/build/report/new/

mkdir app/build/report
mkdir app/build/report/current
mkdir app/build/report/new

PR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "PR BRANCH=$PR_BRANCH"

MERGE_BRANCH=$(git log --merges --grep "Merge pull request" -1 --format=format:%h)
echo "MERGE BRANCH=$MERGE_BRANCH"

# build apk from master and fetch apk info
git checkout $MERGE_BRANCH
./gradlew assembleRelease
cp app/build/outputs/apk/app-release.apk app/build/report/current/app-release.apk
unzip app/build/report/current/app-release.apk -d app/build/report/current > /dev/null

# switch back to PR branch
git checkout $PR_BRANCH
./gradlew assembleRelease
cp app/build/outputs/apk/app-release.apk app/build/report/new/app-release.apk
unzip app/build/report/new/app-release.apk -d app/build/report/new > /dev/null

python app/build/report/build_report.py
