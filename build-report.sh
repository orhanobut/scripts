#!/bin/bash

mkdir app/build/outputs/report
mkdir app/build/outputs/report/current
mkdir app/build/outputs/report/new

PR_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# build apk from master and fetch apk info
git checkout master
./gradlew assembleDebug
cp app/build/outputs/apk/app-debug.apk app/build/outputs/report/current/app-release.apk
unzip app/build/outputs/report/current/app-release.apk

# switch back to PR branch
git checkout $PR_BRANCH
./gradlew assembleDebug
cp app/build/outputs/apk/app-debug.apk app/build/outputs/report/new/app-release.apk
unzip app/build/outputs/report/new/app-release.apk

python .reports/build_report.py
