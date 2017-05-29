#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

echo Running bikeshed on index.src.html
bikeshed -f spec ./index.src.html

if [ -d out ]; then
  echo Copy index.html into out/index.html
  cp index.html out/index.html
fi
