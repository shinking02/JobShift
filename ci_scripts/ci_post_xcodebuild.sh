#!/bin/zsh
#  ci_post_xcodebuild.sh

WHAT_TO_TEST=""

if [ -n "$CI_PULL_REQUEST_NUMBER" ]; then
  PR_INFO=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$CI_PULL_REQUEST_TARGET_REPO/pulls/$CI_PULL_REQUEST_NUMBER")
  
  # https://stackoverflow.com/questions/52399819/invalid-string-control-characters-from-u0000-through-u001f-must-be-escaped-us
  PR_TITLE=$(printf '%s\n' "$PR_INFO" | jq -r '.title')
  PR_BODY=$(printf '%s\n' "$PR_INFO" | jq -r '.body')
  WHAT_TO_TEST="[PR#$CI_PULL_REQUEST_NUMBER]\n$PR_TITLE\n$PR_BODY\n"
fi

COMMIT=$(git fetch --deepen 3 && git log -3 --pretty=format:"%s")

WHAT_TO_TEST=${WHAT_TO_TEST}"[COMMIT]\n$COMMIT"

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  TESTFLIGHT_DIR_PATH=../TestFlight
  mkdir $TESTFLIGHT_DIR_PATH
  echo "$WHAT_TO_TEST" >! $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
fi
