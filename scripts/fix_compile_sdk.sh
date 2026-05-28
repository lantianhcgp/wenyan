#!/bin/bash
# Fix compileSdk version for the app-level Android build file (Groovy & Kotlin DSL)
set -e

SDK_VERSION="${1:-36}"

# Update app-level build.gradle(.kts)
APP_BUILD=$(find android/app -maxdepth 1 -name 'build.gradle*' | head -1)
if [ -n "$APP_BUILD" ]; then
  echo "Updating app: $APP_BUILD"
  if [[ "$APP_BUILD" == *.kts ]]; then
    sed -i "s/compileSdk = .*/compileSdk = $SDK_VERSION/" "$APP_BUILD"
  else
    sed -i "s/compileSdkVersion: .*/compileSdkVersion $SDK_VERSION/" "$APP_BUILD"
    sed -i "s/compileSdk .*/compileSdk $SDK_VERSION/" "$APP_BUILD"
  fi
fi

echo "Done — compileSdk set to $SDK_VERSION"
