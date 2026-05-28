#!/bin/bash
# Fix compileSdk version for all Android Gradle files (Groovy & Kotlin DSL)
set -e

SDK_VERSION="${1:-36}"

# Update root build.gradle(.kts) — force all plugin subprojects to use the target SDK
ROOT_BUILD=$(find android -maxdepth 1 -name 'build.gradle*' | head -1)
if [ -n "$ROOT_BUILD" ]; then
  echo "Updating root: $ROOT_BUILD"
  if [[ "$ROOT_BUILD" == *.kts ]]; then
    # Kotlin DSL: use BaseExtension to cover both Library & Application plugins
    cat >> "$ROOT_BUILD" << 'KOTLIN'
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            ?.compileSdkVersion(36)
    }
}
KOTLIN
    # Fix the SDK version via sed (the heredoc above has hardcoded 36)
    sed -i "s/compileSdkVersion(36)/compileSdkVersion($SDK_VERSION)/" "$ROOT_BUILD"
  else
    # Groovy DSL
    cat >> "$ROOT_BUILD" << GROOVY
subprojects {
    afterEvaluate {
        if (project.hasProperty('android')) {
            android {
                compileSdkVersion $SDK_VERSION
            }
        }
    }
}
GROOVY
  fi
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

echo "Done — compileSdk set to $SDK_VERSION"
