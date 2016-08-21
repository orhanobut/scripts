#!/bin/bash

BUILD_TYPE=$1
if [ -z $BUILD_TYPE ]
  then
   BUILD_TYPE="RELEASE"
fi

echo "$BUILD_TYPE will be used to compare APK info"

GRADLE_BUILD_TYPE="assembleRelease"
APP_NAME="app-release.apk"

if [ $BUILD_TYPE == "DEBUG" ]; then
  GRADLE_BUILD_TYPE="assembleDebug"
  APP_NAME="app-debug.apk"
fi

rm -R app/build/report/current/
rm -R app/build/report/new/

mkdir app/build/report
mkdir app/build/report/current
mkdir app/build/report/new

echo "Fetching build_report.py"
curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/build_report.py -o app/build/report/build_report.py

echo "Fetching apk_info.py"
curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/apk_info.py -o app/build/report/apk_info.py

PR_BRANCH=$(git rev-parse --short HEAD)
echo "PR BRANCH=$PR_BRANCH"

MERGE_BRANCH=$(git log --merges --grep "Merge pull request" -1 --format=format:%h)
echo "MERGE BRANCH=$MERGE_BRANCH"

# build apk from master and fetch apk info
git checkout $MERGE_BRANCH
echo "Current  branch = $MERGE_BRANCH"
echo "Building current apk"
./gradlew $GRADLE_BUILD_TYPE > /dev/null
echo "Copying current apk"
cp "app/build/outputs/apk/$APP_NAME" app/build/report/current/app.apk
echo "Unzipping current apk"
unzip app/build/report/current/app.apk -d app/build/report/current > /dev/null

# switch back to PR branch
git checkout $PR_BRANCH
echo "Current branch = $PR_BRANCH"
echo "Building new apk"
./gradlew $GRADLE_BUILD_TYPE > /dev/null
echo "Copying new apk"
cp "app/build/outputs/apk/$APP_NAME" app/build/report/new/app.apk
echo "Unzipping new apk"
unzip app/build/report/new/app.apk -d app/build/report/new > /dev/null

echo "Building report"
python app/build/report/build_report.py
