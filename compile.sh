#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

bikeshed -f spec ./index.src.html

if [ -d out ]; then
  echo Copy index.html into out/index.html
  cp index.html out/index.html
fi
