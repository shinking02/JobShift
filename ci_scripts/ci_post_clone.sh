#!/bin/bash

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

env_file_path="../JobShift/Env.swift"

typeset -A envValues

envValues[GITHUB_API_TOKEN]=$GITHUB_API_TOKEN

for key in ${(k)envValues}
  sed -i -e "s/${key}/${envValues[$key]}/g" "${env_file_path}"
