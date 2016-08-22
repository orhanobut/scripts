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

REPORT_PATH="report"

rm -R "$REPORT_PATH/current/"
rm -R "$REPORT_PATH/new/"

mkdir "$REPORT_PATH"
mkdir "$REPORT_PATH/current"
mkdir "$REPORT_PATH/new"

echo "Copy checkstyle report"
cp app/build/reports/checkstyle/checkstyle.html "$REPORT_PATH/checkstyle.html"

echo "Copy lint report"
cp app/build/outputs/lint-results-debug.html "$REPORT_PATH/lint.html"

echo "Copy unit tests report"
cp app/build/reports/tests/debug/index.html "$REPORT_PATH/unittests.html"

echo "Fetching build_report.py"
curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/build_report.py -o "$REPORT_PATH/build_report.py"

echo "Fetching apk_info.py"
curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/apk_info.py -o "$REPORT_PATH/apk_info.py"

PR_BRANCH=$(git rev-parse --short HEAD)
echo "PR BRANCH=$PR_BRANCH"

MERGE_BRANCH=$(git log --merges --grep "$COMPARE_COMMIT_GREP" -1 --format=format:%h)
echo "MERGE BRANCH=$MERGE_BRANCH"

# build apk from master and fetch apk info
git checkout $MERGE_BRANCH
echo "Current branch = $MERGE_BRANCH"
echo "Building current apk"
./gradlew $GRADLE_BUILD_TYPE > "$REPORT_PATH/current/log.txt"
echo "Copying current apk"
cp "app/build/outputs/apk/$APP_NAME" "$REPORT_PATH/current/app.apk"
echo "Unzipping current apk"
unzip "$REPORT_PATH/current/app.apk" -d "$REPORT_PATH/current" >> "$REPORT_PATH/current/log.txt"

# switch back to PR branch
git checkout $PR_BRANCH
echo "Current branch = $PR_BRANCH"
echo "Building new apk"
./gradlew clean $GRADLE_BUILD_TYPE > "$REPORT_PATH/new/log.txt"
echo "Copying new apk"
cp "app/build/outputs/apk/$APP_NAME" "$REPORT_PATH/new/app.apk"
echo "Unzipping new apk"
unzip "$REPORT_PATH/new/app.apk" -d "$REPORT_PATH/new" >> "$REPORT_PATH/new/log.txt"

echo "Building report"
python "$REPORT_PATH/build_report.py" $REPORT_PATH
