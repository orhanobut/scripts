# SCRIPTS

All scripts that I use in my daily development

# buildreport
Aggregates all data from each tool report and summarize them in html format in order to use it via email. Following information is provided: 
- **Pull request info**: Which commits are in the pull request
- **Apk info**: All information about the apk. Comparison is also shown between prior the pull request and after
 - **Method count**: Current, Diff, New and Remaining count
 - **Apk Size in mb**: Current, Diff, New
 - **Min sdk version**
 - **Target sdk version**
 - **Permissions**: New added permission are shown in green and annotated. Removed permissions are shown in red and annotated
- **Lint summary**
- **Checkstyle summary**
- **Unit tests summary**: Grouped by test classes. Some test classes are highligted regarding to status
 - **Red**: Failure tests
 - **Orange**: Ignored tests
 - **Blue**: These tests take longer than 1 second, usually unit tests should be super fast

Run the following command in your execute shell. That's it. If you want to compare debug builds, replace RELEASE with DEBUG. If you leave it empty, RELEASE build type will be used as default
```shell
$ curl https://raw.githubusercontent.com/orhanobut/scripts/master/buildreport/build-report.sh -o build-report.sh
$ sh build-report.sh RELEASE
```

[For more details about buildreport](https://github.com/orhanobut/scripts/blob/master/buildreport/README.md)

# git
Set up a git with username, email and the aliases. Invoke the following command in your terminal by adding your username and email. It will setup your git with the given parameters and will add the following aliases automatically.

- Set global user.name
- Set global user.email
- Add the following aliases

```
git l       One line commit messages
git lo      One line commit message along with tags/branch info
git ld      Commits that are not pushed to master yet
git lol     Commits with graph
git s       status 
git ac      Add and commit
```

Replace USERNAME and EMAIL with your information and run in your command line. That's it.

```shell
curl https://raw.githubusercontent.com/orhanobut/scripts/master/git/init-git.sh | bash -s USERNAME EMAIL
```


# android
Initialize all required artifacts for android development
