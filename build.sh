#!/bin/bash
dt=$(date '+%d/%m/%Y');

bundle exec jekyll build
cp -r _site/* /home/javad/Work/Project/other/blog
cd /home/javad/Work/Project/other/blog
git pull
git add .
git commit -m "Update $dt"
git push origin master
