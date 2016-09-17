#!/usr/bin/env bash

NAME=""
EMAIL=""

while (( "$#" )); do
  case "$1" in 
  "--name") 
     shift
     NAME=$1
     ;;
  "--email")
     shift
     EMAIL=$1
     ;;
  esac
  shift
done

if [[ $NAME == "" ]]
  then
    echo "Name is missing. Add your name by using  --name <YOUR_NAME>"
    exit 1
fi

if [[ $EMAIL == "" ]]
  then
    echo "Email is missing. Add your email by using  --email <YOUR_EMAIL>"
    exit 1
fi

echo "Setting username as $1"
git config --global user.name $NAME

echo "Setting user email as $2"
git config --global user.email $EMAIL

echo "Setting aliases"
echo "l -> log --oneline"
git config --global alias.l "log --oneline"

echo "lo -> log --oneline --decorate"
git config --global alias.lo "log --oneline --decorate"

echo "ld -> log --oneline origin/master.."
git config --global alias.ld "log --oneline origin/master.."

echo "lds -> log --oneline origin/master.. --shortstat"
git config --global alias.lds "log --oneline origin/master.. --shortstat"

echo "lol -> log --oneline --decorate --graph"
git config --global alias.lol "log --oneline --decorate --graph"

echo "s -> status"
git config --global alias.s "status"

echo "ac -> git add . && git commit -am"
git config --global alias.ac "!git add . && git commit -am"

echo "c -> git commit"
git config --global alias.c "commit"

echo "cm -> git commit -m "
git config --global alias.cm "commit -m"

echo "pom -> git pull origin master"
git config --global alias.pom "pull origin master" 

echo "b -> git branch"
git config --global alias.b "branch"

echo "co -> git checkout"
git config --global alias.co "checkout"




