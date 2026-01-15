# Multi-Bootstrap

Flutter multiplatform app bootstrap. Ready for iOS, Android, and Web.

## Stack

- **Framework**: Flutter 3.19+
- **State Management**: Riverpod
- **Routing**: GoRouter
- **Networking**: Dio
- **Monorepo**: Melos
- **CI**: GitHub Actions

## Quick Start

### 1. Clone and Initialize

```bash
git clone https://github.com/YOUR_USER/multi-bootstrap.git myapp
cd myapp

# Initialize with your app name and bundle ID
./scripts/init.sh myapp com.yourcompany.myapp
```

### 2. Setup

```bash
# Install dependencies and bootstrap packages
make bootstrap

# Generate code (freezed, riverpod, json_serializable)
make generate
```

### 3. Run

```bash
# Run with dev flavor
make run-dev

# Run on web
make run-web

# Run with specific flavor
make run-stage
make run-prod
```

## Project Structure

```
├── apps/
│   └── mobile/              # Main Flutter app
│       ├── lib/
│       │   └── main.dart
│       ├── android/         # Android config + flavors
│       ├── ios/             # iOS config + schemes
│       ├── web/             # Web assets
│       ├── .env.dev         # Dev environment
│       ├── .env.stage       # Stage environment
│       └── .env.prod        # Prod environment
│
├── packages/
│   ├── core/                # Shared: env, networking, DI
│   ├── ui/                  # Design system, shared widgets
│   ├── routing/             # GoRouter configuration
│   └── features/
│       └── auth/            # Sample feature module
│
├── melos.yaml               # Monorepo configuration
├── Makefile                 # Dev commands
└── .github/workflows/       # CI configuration
```

## Packages

| Package | Purpose |
|---------|---------|
| `core` | Environment config, API client (Dio), providers |
| `ui` | Theme, colors, spacing, shared widgets |
| `routing` | GoRouter setup, route definitions |
| `auth` | Sample auth feature (login, register, state) |

## Commands

```bash
# Setup
make setup           # Install Flutter tooling
make bootstrap       # Bootstrap all packages

# Development
make run-dev         # Run with dev flavor
make run-stage       # Run with stage flavor
make run-prod        # Run with prod flavor
make run-web         # Run on web (dev)

# Quality
make analyze         # Run flutter analyze
make test            # Run tests with coverage
make format          # Format all code
make format-check    # Check formatting

# Build
make build-web       # Build web release
make build-android   # Build Android APK
make build-ios       # Build iOS (no codesign)

# Code Generation
make generate        # Run build_runner (freezed, riverpod, etc.)

# Cleanup
make clean           # Clean all packages
```

## Environment & Flavors

### Environment Files

| File | Purpose |
|------|---------|
| `.env.dev` | Local development |
| `.env.stage` | Staging environment |
| `.env.prod` | Production |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `FLAVOR` | Current flavor (dev/stage/prod) |
| `API_BASE_URL` | Backend API URL |
| `APP_NAME` | Display name |
| `ENABLE_LOGGING` | Enable debug logging |

### Running with Flavors

```bash
# Using melos scripts
melos run:dev
melos run:stage
melos run:prod

# Using flutter directly
cd apps/mobile
flutter run --flavor dev --dart-define-from-file=.env.dev
flutter run --flavor stage --dart-define-from-file=.env.stage
flutter run --flavor prod --dart-define-from-file=.env.prod
```

## Adding a New Feature

1. Create package:
```bash
mkdir -p packages/features/my_feature/lib/src
```

2. Add `pubspec.yaml`:
```yaml
name: my_feature
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  core:
    path: ../../core
  ui:
    path: ../../ui
```

3. Add to `apps/mobile/pubspec.yaml`:
```yaml
dependencies:
  my_feature:
    path: ../../packages/features/my_feature
```

4. Bootstrap:
```bash
melos bootstrap
```

## Architecture

### Feature Structure

```
packages/features/auth/
├── lib/
│   ├── auth.dart           # Public exports
│   └── src/
│       ├── models/         # Data models (freezed)
│       ├── repository/     # Data layer
│       ├── providers/      # Riverpod providers
│       └── ui/             # Widgets/pages
└── test/
```

### State Management

Uses Riverpod with code generation:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login({...}) async {
    state = const AuthState.loading();
    // ...
  }
}
```

### Routing

GoRouter with named routes:

```dart
context.goNamed(RouteNames.home);
context.pushNamed(RouteNames.profile);
```

## CI/CD

GitHub Actions runs on push/PR to main:

1. **Analyze**: `flutter analyze` + format check
2. **Test**: Run tests with coverage
3. **Build Web**: Build and upload artifacts
4. **Build Android**: Build APK (main branch only)

## Platform Setup

### Android

Flavors configured in `apps/mobile/android/app/build.gradle`:
- `dev`: `.dev` suffix, debug name
- `stage`: `.stage` suffix
- `prod`: Production bundle ID

### iOS

Schemes configured via xcconfig files in `apps/mobile/ios/Runner/Config/`:
- `Dev.xcconfig`
- `Stage.xcconfig`
- `Prod.xcconfig`

**Note**: You'll need to configure Xcode schemes manually after first `flutter build ios`.

### Web

Built with dart-define from environment files. No special configuration needed.

## License

MIT
