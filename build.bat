@echo off
set dt=%date%

bundle exec jekyll build
xcopy D:\Project\other\jekyll-theme-chirpy\_site\* D:\Project\other\blog /E /H /C /I
cd /d D:\Project\other\blog
git pull
git add .
git commit -m "Update %dt%"
git push origin master