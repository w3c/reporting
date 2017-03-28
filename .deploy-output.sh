#!/bin/bash
set -ev
STATUS=`git log -1 --pretty=oneline`

mkdir out
cp index.html ./out/

cd out
git init
git config user.name "Travis-CI"
git config user.email "travis-ci"
ls
git add .
git commit -m "Built by Travis-CI: $STATUS"
git status

GH_REPO="@github.com/wicg/reporting.git"
FULL_REPO="https://$GH_TOKEN$GH_REPO"
git push --force --quiet $FULL_REPO master:gh-pages > /dev/null 2>&1
