#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Cross-platform sed in-place editing
# macOS sed requires '' after -i, GNU sed does not
sed_inplace() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Check if project appears to already be initialized
check_already_initialized() {
    if ! grep -q '"name": "MyApp"' "$PROJECT_ROOT/apps/mobile/web/manifest.json" 2>/dev/null; then
        warn "Project appears to already be initialized (not using default 'MyApp' name)"
        echo ""
        read -p "Continue anyway? This may cause issues. [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
        echo ""
    fi
}

# Get user input interactively or from command line arguments
get_user_input() {
    echo ""
    echo "========================================="
    echo "  Flutter Project Initialization"
    echo "========================================="
    echo ""

    # App Name (display name)
    if [ -n "$1" ]; then
        APP_DISPLAY_NAME="$1"
    else
        read -p "App Name (e.g., 'My Awesome App'): " APP_DISPLAY_NAME
    fi

    if [ -z "$APP_DISPLAY_NAME" ]; then
        error "App name is required"
    fi

    # Organization
    if [ -n "$2" ]; then
        ORG_NAME="$2"
    else
        read -p "Organization (e.g., 'com.mycompany') [com.example]: " ORG_NAME
    fi

    if [ -z "$ORG_NAME" ]; then
        ORG_NAME="com.example"
        info "Using default organization: $ORG_NAME"
    fi
}

# Validate inputs and create transformed versions
validate_and_transform() {
    # Validate organization format (reverse domain notation)
    if [[ ! "$ORG_NAME" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
        error "Organization must be in reverse domain format (e.g., com.mycompany)"
    fi

    # Transform app name for different uses:
    # - Display name: "My Awesome App" (as entered, for UI)
    # - Package name: "my_awesome_app" (lowercase, spaces to underscores, for Dart packages)
    # - Bundle suffix: "myawesomeapp" (lowercase, no spaces/special chars, for bundle IDs)

    APP_PACKAGE_NAME=$(echo "$APP_DISPLAY_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_')
    APP_BUNDLE_SUFFIX=$(echo "$APP_DISPLAY_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')

    # Construct bundle ID
    BUNDLE_ID="${ORG_NAME}.${APP_BUNDLE_SUFFIX}"

    # Validate package name starts with a letter
    if [[ ! "$APP_PACKAGE_NAME" =~ ^[a-z] ]]; then
        error "App name must start with a letter"
    fi

    # Validate bundle ID length (iOS limit is 155 characters)
    if [ ${#BUNDLE_ID} -gt 155 ]; then
        error "Bundle ID exceeds maximum length of 155 characters"
    fi
}

# Show configuration summary and confirm
show_summary_and_confirm() {
    echo ""
    echo "Configuration Summary:"
    echo "  App Display Name: $APP_DISPLAY_NAME"
    echo "  Package Name:     $APP_PACKAGE_NAME"
    echo "  Organization:     $ORG_NAME"
    echo "  Bundle ID:        $BUNDLE_ID"
    echo "  Dev Bundle ID:    $BUNDLE_ID.dev"
    echo "  Stage Bundle ID:  $BUNDLE_ID.stage"
    echo ""

    read -p "Proceed with initialization? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    echo ""
}

# Update Android configuration files
update_android_files() {
    log "Updating Android configuration..."

    local BUILD_GRADLE="$PROJECT_ROOT/apps/mobile/android/app/build.gradle"
    local STRINGS_XML="$PROJECT_ROOT/apps/mobile/android/app/src/main/res/values/strings.xml"

    # Update namespace
    sed_inplace "s/namespace \"com\.example\.mobile\"/namespace \"$BUNDLE_ID\"/g" "$BUILD_GRADLE"

    # Update applicationId
    sed_inplace "s/applicationId \"com\.example\.mobile\"/applicationId \"$BUNDLE_ID\"/g" "$BUILD_GRADLE"

    # Update app display names in product flavors
    sed_inplace "s/resValue \"string\", \"app_name\", \"MyApp Dev\"/resValue \"string\", \"app_name\", \"$APP_DISPLAY_NAME Dev\"/g" "$BUILD_GRADLE"
    sed_inplace "s/resValue \"string\", \"app_name\", \"MyApp Stage\"/resValue \"string\", \"app_name\", \"$APP_DISPLAY_NAME Stage\"/g" "$BUILD_GRADLE"
    sed_inplace "s/resValue \"string\", \"app_name\", \"MyApp\"/resValue \"string\", \"app_name\", \"$APP_DISPLAY_NAME\"/g" "$BUILD_GRADLE"

    # Update strings.xml
    sed_inplace "s/<string name=\"app_name\">MyApp<\/string>/<string name=\"app_name\">$APP_DISPLAY_NAME<\/string>/g" "$STRINGS_XML"
}

# Update iOS configuration files
update_ios_files() {
    log "Updating iOS configuration..."

    local CONFIG_DIR="$PROJECT_ROOT/apps/mobile/ios/Runner/Config"

    # Dev config
    sed_inplace "s/PRODUCT_BUNDLE_IDENTIFIER=com\.example\.mobile\.dev/PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID.dev/g" "$CONFIG_DIR/Dev.xcconfig"
    sed_inplace "s/PRODUCT_NAME=MyApp Dev/PRODUCT_NAME=$APP_DISPLAY_NAME Dev/g" "$CONFIG_DIR/Dev.xcconfig"
    sed_inplace "s/DISPLAY_NAME=MyApp Dev/DISPLAY_NAME=$APP_DISPLAY_NAME Dev/g" "$CONFIG_DIR/Dev.xcconfig"

    # Stage config
    sed_inplace "s/PRODUCT_BUNDLE_IDENTIFIER=com\.example\.mobile\.stage/PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID.stage/g" "$CONFIG_DIR/Stage.xcconfig"
    sed_inplace "s/PRODUCT_NAME=MyApp Stage/PRODUCT_NAME=$APP_DISPLAY_NAME Stage/g" "$CONFIG_DIR/Stage.xcconfig"
    sed_inplace "s/DISPLAY_NAME=MyApp Stage/DISPLAY_NAME=$APP_DISPLAY_NAME Stage/g" "$CONFIG_DIR/Stage.xcconfig"

    # Prod config
    sed_inplace "s/PRODUCT_BUNDLE_IDENTIFIER=com\.example\.mobile$/PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID/g" "$CONFIG_DIR/Prod.xcconfig"
    sed_inplace "s/PRODUCT_NAME=MyApp$/PRODUCT_NAME=$APP_DISPLAY_NAME/g" "$CONFIG_DIR/Prod.xcconfig"
    sed_inplace "s/DISPLAY_NAME=MyApp$/DISPLAY_NAME=$APP_DISPLAY_NAME/g" "$CONFIG_DIR/Prod.xcconfig"
}

# Update Web configuration files
update_web_files() {
    log "Updating Web configuration..."

    local INDEX_HTML="$PROJECT_ROOT/apps/mobile/web/index.html"
    local MANIFEST_JSON="$PROJECT_ROOT/apps/mobile/web/manifest.json"

    # Update index.html
    sed_inplace "s/<title>MyApp<\/title>/<title>$APP_DISPLAY_NAME<\/title>/g" "$INDEX_HTML"
    sed_inplace "s/content=\"MyApp\"/content=\"$APP_DISPLAY_NAME\"/g" "$INDEX_HTML"

    # Update manifest.json
    sed_inplace "s/\"name\": \"MyApp\"/\"name\": \"$APP_DISPLAY_NAME\"/g" "$MANIFEST_JSON"
    sed_inplace "s/\"short_name\": \"MyApp\"/\"short_name\": \"$APP_DISPLAY_NAME\"/g" "$MANIFEST_JSON"
}

# Update environment files
update_env_files() {
    log "Updating environment files..."

    local ENV_DIR="$PROJECT_ROOT/apps/mobile"

    sed_inplace "s/APP_NAME=MyApp Dev/APP_NAME=$APP_DISPLAY_NAME Dev/g" "$ENV_DIR/.env.dev"
    sed_inplace "s/APP_NAME=MyApp Stage/APP_NAME=$APP_DISPLAY_NAME Stage/g" "$ENV_DIR/.env.stage"
    sed_inplace "s/APP_NAME=MyApp$/APP_NAME=$APP_DISPLAY_NAME/g" "$ENV_DIR/.env.prod"
}

# Update Dart package names
update_dart_packages() {
    log "Updating Dart package names..."

    # Update melos.yaml
    sed_inplace "s/name: multi_bootstrap/name: $APP_PACKAGE_NAME/g" "$PROJECT_ROOT/melos.yaml"

    # Update root pubspec.yaml
    sed_inplace "s/name: multi_bootstrap/name: ${APP_PACKAGE_NAME}/g" "$PROJECT_ROOT/pubspec.yaml"

    # Update mobile app pubspec.yaml
    sed_inplace "s/name: mobile/name: $APP_PACKAGE_NAME/g" "$PROJECT_ROOT/apps/mobile/pubspec.yaml"
}

# Main execution
main() {
    check_already_initialized
    get_user_input "$1" "$2"
    validate_and_transform
    show_summary_and_confirm

    cd "$PROJECT_ROOT"

    update_android_files
    update_ios_files
    update_web_files
    update_env_files
    update_dart_packages

    echo ""
    log "Project initialized successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: make bootstrap"
    echo "  2. Run: make generate"
    echo "  3. Run: make run-dev"
    echo ""
    echo "Your app configuration:"
    echo "  - Display Name: $APP_DISPLAY_NAME"
    echo "  - Bundle ID: $BUNDLE_ID"
    echo ""
}

main "$@"
