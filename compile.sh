#!/bin/bash

shopt -q nullglob
NULLGLOB_WAS_SET=$?
shopt -s nullglob
FILES=$(echo *.bs)
if [ 1 -eq $NULLGLOB_WAS_SET ]; then
  shopt -u nullglob
fi

set -e # Exit with nonzero exit code if anything fails

for SPEC in index.src.html $FILES; do
  echo Running bikeshed on $SPEC
  if which bikeshed; then
    bikeshed -f spec $SPEC
  else
    SPEC_OUT=${SPEC%.bs}.html
    HTTP_STATUS=$(curl https://api.csswg.org/bikeshed/ \
                       --output ${SPEC_OUT} \
                       --write-out "%{http_code}" \
                       --header "Accept: text/plain, text/html" \
                       -F file=@${SPEC})
    if [ "$HTTP_STATUS" -ne "200" ]; then
      echo ""; cat $SPEC_OUT; echo ""
      rm -f $SPEC_OUT
      exit 1
    fi
  fi
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
