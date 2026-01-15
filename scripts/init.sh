#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_NAME="${1:-}"
BUNDLE_ID="${2:-}"

if [ -z "$APP_NAME" ]; then
    echo "Usage: ./scripts/init.sh <app-name> [bundle-id]"
    echo ""
    echo "Example: ./scripts/init.sh myapp com.company.myapp"
    echo ""
    echo "This will:"
    echo "  - Rename 'mobile' to your app name in configs"
    echo "  - Update bundle identifiers"
    echo "  - Update display names"
    echo ""
    exit 1
fi

if [[ ! "$APP_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    error "App name must start with a letter and contain only lowercase letters, numbers, and underscores"
fi

if [ -z "$BUNDLE_ID" ]; then
    BUNDLE_ID="com.example.${APP_NAME}"
    warn "No bundle ID provided, using default: $BUNDLE_ID"
fi

echo ""
echo "Initializing project as: $APP_NAME"
echo "Bundle ID: $BUNDLE_ID"
echo ""

cd "$PROJECT_ROOT"

APP_NAME_PASCAL=$(echo "$APP_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')
DISPLAY_NAME="$APP_NAME_PASCAL"

log "Updating melos.yaml..."
sed -i.bak "s/name: multi_bootstrap/name: $APP_NAME/g" melos.yaml
rm -f melos.yaml.bak

log "Updating root pubspec.yaml..."
sed -i.bak "s/name: multi_bootstrap_workspace/name: ${APP_NAME}_workspace/g" pubspec.yaml
rm -f pubspec.yaml.bak

log "Updating apps/mobile/pubspec.yaml..."
sed -i.bak "s/name: mobile/name: $APP_NAME/g" apps/mobile/pubspec.yaml
rm -f apps/mobile/pubspec.yaml.bak

log "Updating Android bundle ID..."
sed -i.bak "s/com.example.mobile/$BUNDLE_ID/g" apps/mobile/android/app/build.gradle
rm -f apps/mobile/android/app/build.gradle.bak

log "Updating Android namespace..."
sed -i.bak "s/namespace \"com.example.mobile\"/namespace \"$BUNDLE_ID\"/g" apps/mobile/android/app/build.gradle
rm -f apps/mobile/android/app/build.gradle.bak

log "Updating Android app names..."
sed -i.bak "s/MyApp Dev/${DISPLAY_NAME} Dev/g" apps/mobile/android/app/build.gradle
sed -i.bak "s/MyApp Stage/${DISPLAY_NAME} Stage/g" apps/mobile/android/app/build.gradle
sed -i.bak "s/\"MyApp\"/\"${DISPLAY_NAME}\"/g" apps/mobile/android/app/build.gradle
rm -f apps/mobile/android/app/build.gradle.bak

log "Updating iOS bundle IDs..."
for config in apps/mobile/ios/Runner/Config/*.xcconfig; do
    sed -i.bak "s/com.example.mobile/$BUNDLE_ID/g" "$config"
    rm -f "$config.bak"
done

log "Updating iOS app names..."
for config in apps/mobile/ios/Runner/Config/*.xcconfig; do
    sed -i.bak "s/MyApp Dev/${DISPLAY_NAME} Dev/g" "$config"
    sed -i.bak "s/MyApp Stage/${DISPLAY_NAME} Stage/g" "$config"
    sed -i.bak "s/MyApp/${DISPLAY_NAME}/g" "$config"
    rm -f "$config.bak"
done

log "Updating web manifest..."
sed -i.bak "s/\"name\": \"MyApp\"/\"name\": \"${DISPLAY_NAME}\"/g" apps/mobile/web/manifest.json
sed -i.bak "s/\"short_name\": \"MyApp\"/\"short_name\": \"${DISPLAY_NAME}\"/g" apps/mobile/web/manifest.json
rm -f apps/mobile/web/manifest.json.bak

log "Updating web index.html..."
sed -i.bak "s/<title>MyApp<\/title>/<title>${DISPLAY_NAME}<\/title>/g" apps/mobile/web/index.html
sed -i.bak "s/content=\"MyApp\"/content=\"${DISPLAY_NAME}\"/g" apps/mobile/web/index.html
rm -f apps/mobile/web/index.html.bak

log "Updating .env files..."
for env in apps/mobile/.env.*; do
    sed -i.bak "s/APP_NAME=MyApp/APP_NAME=${DISPLAY_NAME}/g" "$env"
    rm -f "$env.bak"
done

echo ""
log "Project initialized as: $APP_NAME"
echo ""
echo "Next steps:"
echo "  1. Run: make bootstrap"
echo "  2. Run: make generate (to generate freezed/riverpod code)"
echo "  3. Run: make run-dev (to start the app)"
echo ""
echo "Your apps will use:"
echo "  - Bundle ID: $BUNDLE_ID"
echo "  - Display Name: $DISPLAY_NAME"
echo ""
