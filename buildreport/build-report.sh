#!/bin/bash

echo "Downloading build report generator"
curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/build-report.sh -o init-report.sh

echo "Running build report with $1"
sh init-report.sh $1