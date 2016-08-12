Summary report aggregator for the build result:

- Pull request commits: Show which commits are 
- Apk Info
 - Method count
 - Apk Size
 - Min sdk version
 - Target sdk version
 - Permissions
- Lint summary
- Checkstyle summary
- Unit tests summary


# Usage
Add the following commands to your execute shell in post build

```shell
$ mkdir app/build/report
$ curl https://raw.githubusercontent.com/orhanobut/buildreport/master/build-report.sh -o app/build/report/build-report.sh
$ sh app/build/report/build-report.sh
```
