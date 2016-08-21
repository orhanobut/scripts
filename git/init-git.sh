#!/usr/bin/env bash

if [ -z $1 ]
  then 
    echo "No username is provided. Add your username and email as arguments. ./init-git YOUR_USERNAME YOUR_EMAIL"
    exit 1
fi

if [ -z $2 ]  
  then
    echo "No email is provided. Add your email as argument. ./init-git $1 YOUR_EMAIL"
    exit 1
fi

echo "Setting username as $1"
git config --global user.name $1

echo "Setting user email as $2"
git config --global user.email $2

echo "Setting aliases"
echo "l -> log --oneline"
git config --global alias.l "log --oneline"

echo "lo -> log --oneline --decorate"
git config --global alias.lo "log --oneline --decorate"

echo "ld -> log --oneline origin/master.."
git config --global alias.ld "log --oneline origin/master.."

echo "lol -> log --oneline --decorate --graph"
git config --global alias.lol "log --oneline --decorate --graph"

echo "s -> status"
git config --global alias.s "status"

echo "ac -> git add . && git commit -am"
git config --global alias.ac "!git add . && git commit -am"

