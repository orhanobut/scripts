#!/usr/bin/env bash

while [[ -z "$USERNAME" ]]
do
  read -p "Enter your name:" USERNAME
done 

while [[ -z "$EMAIL" ]]
do
  read -p "Enter your email:" EMAIL
done

echo "Setting username as $USERNAME"
git config --global user.name $USERNAME

echo "Setting user email as $EMAIL"
git config --global user.email $EMAIL

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

