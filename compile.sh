#!/bin/bash

function run_bikeshed {
  echo Running bikeshed on $1
  if which bikeshed; then
    bikeshed -f spec $1
  else
    HTTP_STATUS=$(curl https://api.csswg.org/bikeshed/ \
                       --output $2 \
                       --write-out "%{http_code}" \
                       --header "Accept: text/plain, text/html" \
                       -F file=@$1)
    if [ "$HTTP_STATUS" -ne "200" ]; then
      echo ""; cat $2; echo ""
      rm -f $2
      exit 1
    fi
  fi
}

shopt -q nullglob
NULLGLOB_WAS_SET=$?
shopt -s nullglob
FILES=$(echo *.bs)
if [ 1 -eq $NULLGLOB_WAS_SET ]; then
  shopt -u nullglob
fi

set -e # Exit with nonzero exit code if anything fails

run_bikeshed index.src.html index.html
for SPEC in $FILES; do
  run_bikeshed $SPEC ${SPEC%.bs}.html
done

OUTDIR=${1:-out}

mkdir -p $OUTDIR

if [ -d $OUTDIR ]; then
  echo Move index.html into $OUTDIR/index.html
  mv index.html $OUTDIR/$SPEC_OUT
  for SPEC in $FILES; do
    SPEC_OUT=${SPEC%.bs}.html
    if [ -f $SPEC_OUT ]; then
      echo Move $SPEC_OUT into $OUTDIR/$SPEC_OUT
      mv $SPEC_OUT $OUTDIR/$SPEC_OUT
    fi
  done
fi
