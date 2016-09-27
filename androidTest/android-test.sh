#!/usr/bin/env bash

PACKAGE_NAME=""
RUNNER=""
APP_ID=""

while (( "$#" )); do
  case "$1" in 
  "--package") 
     shift
     PACKAGE_NAME=$1
     ;;
  "--app-id")
     shift
     APP_ID=$1
     ;;
  "--runner")
     shift
     RUNNER=$1
     ;;
  esac
  shift
done

if [[ ( $PACKAGE_NAME == "" ) || ( $APP_ID == "" ) || ( $RUNNER == "") ]]
  then
    echo "Required parameters are missing, --package, --app-id and --runner must be set"
    exit 1
fi

echo "Package name under test = $PACKAGE_NAME"
echo "App id under test = $APP_ID"
echo "Runner for tests = $RUNNER"

# Installing debug apk
if [ ! -e app/build/outputs/apk/app-debug.apk ]
  then
    ./gradlew assembleDebug > /dev/null
fi
adb push app/build/outputs/apk/app-debug.apk "/data/local/tmp/$APP_ID"
adb shell pm install -r "/data/local/tmp/$APP_ID"

# Installing test apk
./gradlew assembleAndroidTest >> /dev/null
adb push app/build/outputs/apk/app-debug-androidTest.apk "/data/local/tmp/$APP_ID.test"
adb shell pm install -r "/data/local/tmp/$APP_ID.test"

# Running tests
adb shell am instrument -w -r -e package "$PACKAGE_NAME" -e debug false "$APP_ID.test/$RUNNER" > android-test-log.txt

cat android-test-log.txt

# Generate report
REPORT_FILE=$(echo $PACKAGE_NAME | tr '.' '_').txt

grep "Time" android-test-log.txt >> $REPORT_FILE
grep -e "OK (" android-test-log.txt >> $REPORT_FILE
grep -e "Tests run" android-test-log.txt >> $REPORT_FILE
sed -n "s/INSTRUMENTATION_STATUS: class=//gp" android-test-log.txt | uniq >> $REPORT_FILE

if grep "OK (" android-test-log.txt
then
  echo "FUNCTIONAL TESTS SUCCESS"
  echo "FUNCTIONAL TESTS SUCCESS" >> android-test-log.txt
else
  echo "FUNCTIONAL TESTS FAILED"
  echo "FUNCTIONAL TESTS FAILED" >> android-test-log.txt
fi
