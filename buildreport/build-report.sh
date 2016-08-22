#!/bin/bash

BUILD_TYPE=$1
COMPARE_COMMIT_GREP=$2

if [ -z $BUILD_TYPE ]
  then
   BUILD_TYPE="RELEASE"
fi

if [ -z $COMPARE_COMMIT_GREP ]
  then
    COMPARE_COMMIT_GREP="Merge pull request"
fi

GRADLE_BUILD_TYPE="assembleRelease"
APP_NAME="app-release.apk"

if [ $BUILD_TYPE == "DEBUG" ]
  then
    GRADLE_BUILD_TYPE="assembleDebug"
    APP_NAME="app-debug.apk"
fi

echo "Build type : $BUILD_TYPE"
echo "Gradle build command : ./gradlew $GRADLE_BUILD_TYPE"
echo "App-name : $APP_NAME"
echo "Compare commit grep : $COMPARE_COMMIT_GREP"

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

MERGE_BRANCH=$(git log --merges --grep "$COMPARE_COMMIT_GREP" -1 --format=format:%h)
echo "MERGE BRANCH=$MERGE_BRANCH"

# build apk from master and fetch apk info
git checkout $MERGE_BRANCH
echo "Current  branch = $MERGE_BRANCH"
echo "Building current apk"
./gradlew $GRADLE_BUILD_TYPE > app/build/report/current/log.txt
echo "Copying current apk"
cp "app/build/outputs/apk/$APP_NAME" app/build/report/current/app.apk
echo "Unzipping current apk"
unzip app/build/report/current/app.apk -d app/build/report/current >> app/build/report/current/log.txt

# switch back to PR branch
git checkout $PR_BRANCH
echo "Current branch = $PR_BRANCH"
echo "Building new apk"
./gradlew $GRADLE_BUILD_TYPE > app/build/report/new/log.txt
echo "Copying new apk"
cp "app/build/outputs/apk/$APP_NAME" app/build/report/new/app.apk
echo "Unzipping new apk"
unzip app/build/report/new/app.apk -d app/build/report/new >> app/build/report/new/log.txt

echo "Building report"
python app/build/report/build_report.py
