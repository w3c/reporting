#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

echo Running bikeshed on index.src.html
bikeshed -f spec ./index.src.html

echo Running bikeshed on network-reporting.bs
bikeshed -f spec ./network-reporting.bs

if [ -d out ]; then
  echo Copy index.html into out/index.html
  cp index.html out/index.html
  echo Copy network-reporting.html into out/network-reporting.html
  cp network-reporting.html out/network-reporting.html
fi
