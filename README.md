# SCRIPTS

All scripts that I use in my daily development

# buildreport
Aggregates all data from the generated build reports and summarize them in one html file, which you can send it via email.



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
curl https://goo.gl/nw4F9W | bash -s USERNAME EMAIL
```


# android
Initialize all required artifacts for android development
