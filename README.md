Summary report aggregator for github pull requests. 

- Pull request commits: Show which commits are 
- Apk Info. Comparison is also shown between before the pull request and after merge
 - **Method count**
 - **Apk Size**
 - **Min sdk version**
 - **Target sdk version**
 - **Permissions**: New added permission are shown in green and annotated. Removed permissions are shown in red and annotated
- Lint summary
- Checkstyle summary
- Unit tests summary: Some tests are highligted based on the status
 - **Red**: Failure tests
 - **Orange**: Ignored tests
 - **Blue**: These tests take longer than 1 second, usually unit tests should be super fast

<img src='https://github.com/orhanobut/buildreport/blob/master/art/screenshot.png'/>

# Usage
Add the following commands to your execute shell in post build

```shell
$ mkdir app/build/report
$ curl https://raw.githubusercontent.com/orhanobut/buildreport/master/build-report.sh -o app/build/report/build-report.sh
$ sh app/build/report/build-report.sh
```
