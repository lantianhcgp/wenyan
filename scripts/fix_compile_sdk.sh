#!/bin/bash
# Fix compileSdk version for all Android Gradle files (Groovy & Kotlin DSL)
set -e

SDK_VERSION="${1:-36}"

# Update root build.gradle(.kts)
ROOT_BUILD=$(find android -maxdepth 1 -name 'build.gradle*' | head -1)
if [ -n "$ROOT_BUILD" ]; then
  echo "Updating root: $ROOT_BUILD"
  if [[ "$ROOT_BUILD" == *.kts ]]; then
    cat >> "$ROOT_BUILD" << 'KOTLIN'
subprojects {
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.internal.dsl.BaseAppModuleExtension> {
            compileSdkVersion(36)
        }
    }
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            compileSdkVersion(36)
        }
    }
}
KOTLIN
    sed -i "s/compileSdkVersion(36)/compileSdkVersion($SDK_VERSION)/" "$ROOT_BUILD"
  else
    cat >> "$ROOT_BUILD" << GROOVY
subprojects {
    plugins.withId('com.android.application') {
        android.compileSdkVersion $SDK_VERSION
    }
    plugins.withId('com.android.library') {
        android.compileSdkVersion $SDK_VERSION
    }
}
GROOVY
  fi
  echo "Updated root: $ROOT_BUILD"
fi

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

# Disable AAR metadata check so plugins compiled against older SDKs don't block the build
PROPS_FILE="android/gradle.properties"
if [ -f "$PROPS_FILE" ]; then
  if ! grep -q "android.enableAarMetadataCheck" "$PROPS_FILE"; then
    echo "android.enableAarMetadataCheck=false" >> "$PROPS_FILE"
    echo "Disabled AAR metadata check in $PROPS_FILE"
  fi
fi

echo "Done — compileSdk set to $SDK_VERSION"
