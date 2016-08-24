#!/usr/bin/env bash

if [ -z $1 ]
then
  echo "Missing applicationId, ie: $ sh android-test.sh <APPLICATION_ID> <PACKAGE UNDER TEST> <RUNNER>"
fi

APPLICATION_ID=$1

if [ -z $2 ]
then
  echo "Missing package name. ie: $ sh android-test.sh <APPLICATION_ID> <PACKAGE UNDER TEST> <RUNNER>"
  exit 1
fi

PACKAGE_NAME_UNDER_TEST=$2

if [ -z $3 ]
then
  echo "Missing runner parameter. ie: $ sh android-test.sh <APPLICATION_ID> <PACKAGE UNDER TEST> <RUNNER>"
fi

RUNNER=$3

DEBUG_APK="app/buildss/outputs/apk/app-debug.apk"
if [ ! -e "DEBUG_APK" ]
then
  ./gradlew assembleDebug
fi

# Installing debug apk
adb push app/build/outputs/apk/app-debug.apk "/data/local/tmp/$APPLICATION_ID"
adb shell pm install -r "/data/local/tmp/$APPLICATION_ID"

# Installing test apk
./gradlew assembleAndroidTest
adb push app/build/outputs/apk/app-debug-androidTest-unaligned.apk "/data/local/tmp/$APPLICATION_ID.test"
adb shell pm install -r "/data/local/tmp/$APPLICATION_ID.test"

# Running tests
adb shell am instrument -w -r -e package "$PACKAGE_NAME_UNDER_TEST" -e debug false "$APPLICATION_ID.test/$RUNNER"