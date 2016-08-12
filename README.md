BuildReport aggregates all data from each tool report and summarize them in html format in order to use it via email. 

- **PR Info**: Which commits are in the pull request
- **Apk Info**: All information about the apk. Comparison is also shown between before the pull request and after merge
 - **Method count**: Current, Diff, New and Remaining count
 - **Apk Size in mb**: Current, Diff, New
 - **Min sdk version**
 - **Target sdk version**
 - **Permissions**: New added permission are shown in green and annotated. Removed permissions are shown in red and annotated
- **Lint summary**
- **Checkstyle summary**
- **Unit tests summary**: Some tests are highligted based on the status
 - **Red**: Failure tests
 - **Orange**: Ignored tests
 - **Blue**: These tests take longer than 1 second, usually unit tests should be super fast

<img src='https://github.com/orhanobut/buildreport/blob/master/art/screenshot.png'/>

# Usage
Add the following commands to your execute shell in post build. build-report script uses assembleRelease in order to compare and fetch information about apk. If you want to use for debug build, you need to change build-report.sh. I recommend to use release versions

```shell
$ mkdir app/build/report
$ curl https://raw.githubusercontent.com/orhanobut/buildreport/master/build-report.sh -o app/build/report/build-report.sh
$ sh app/build/report/build-report.sh
```

# Generated html file
app/build/report/build-report.html
