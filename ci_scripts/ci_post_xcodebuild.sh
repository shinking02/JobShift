#!/bin/zsh
#  ci_post_xcodebuild.sh

# COMMIT=$(git fetch --deepen 3 && git log -3 --pretty=format:"%s")

# WHAT_TO_TEST="[COMMIT]\n$COMMIT"

# if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
#   TESTFLIGHT_DIR_PATH=../TestFlight
#   mkdir $TESTFLIGHT_DIR_PATH
#   echo "$WHAT_TO_TEST" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
# fi
