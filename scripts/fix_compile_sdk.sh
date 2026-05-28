#!/bin/bash
# Fix compileSdk version for all Android Gradle projects
set -e

SDK_VERSION="${1:-36}"

# 1. Update app-level build.gradle(.kts)
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

# 2. Create Gradle init script to force all subprojects to compileSdk
INIT_DIR="$HOME/.gradle/init.d"
mkdir -p "$INIT_DIR"
cat > "$INIT_DIR/force-compilesdk.gradle" << INITSCRIPT
allprojects {
    afterEvaluate {
        try {
            def androidExt = extensions.findByName("android")
            if (androidExt != null) {
                androidExt.compileSdkVersion($SDK_VERSION)
            }
        } catch (Exception e) {
            // ignore — not an Android project
        }
    }
}
INITSCRIPT
echo "Created init script: $INIT_DIR/force-compilesdk.gradle"

echo "Done — compileSdk forced to $SDK_VERSION for all projects"
