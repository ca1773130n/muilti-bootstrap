# AGENTS.md

AI-agent friendly development guide for this Flutter multiplatform monorepo.

## Overview

This is a Flutter bootstrap project using:
- **Melos** for monorepo management
- **Riverpod** for state management
- **GoRouter** for navigation
- **Freezed** for immutable models

## Quick Reference

```bash
# Bootstrap all packages
make bootstrap

# Generate code (freezed, riverpod, json_serializable)
make generate

# Run with dev flavor
make run-dev

# Run on web
make run-web

# Analyze all packages
make analyze

# Run tests
make test
```

## File Ownership

| Agent | Owns | Commands |
|-------|------|----------|
| **App** | `apps/mobile/**` | `flutter run`, `flutter build` |
| **Core** | `packages/core/**` | Environment, networking, DI |
| **UI** | `packages/ui/**` | Widgets, theme, design system |
| **Routing** | `packages/routing/**` | GoRouter, route definitions |
| **Features** | `packages/features/**` | Feature modules |

## Package Dependencies

```
apps/mobile
├── core
├── ui
├── routing
└── features/auth
    ├── core
    └── ui
```

## Code Generation

After modifying files with `@freezed`, `@riverpod`, or `@JsonSerializable`:

```bash
make generate
```

This runs `build_runner` in all packages that depend on it.

## Adding a Feature

1. Create package structure:
```
packages/features/my_feature/
├── lib/
│   ├── my_feature.dart       # Exports
│   └── src/
│       ├── models/           # freezed models
│       ├── repository/       # data layer
│       ├── providers/        # riverpod providers
│       └── ui/               # widgets
├── test/
└── pubspec.yaml
```

2. Add dependency in `apps/mobile/pubspec.yaml`

3. Run `melos bootstrap`

## Conventions

### Models

Use freezed for immutable data:

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Providers

Use riverpod_generator:

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => const MyState.initial();
}
```

### Routes

Add routes in `packages/routing/lib/src/routes.dart` and names in `route_names.dart`.

## Pre-Commit Checklist

1. `make analyze` - Zero errors
2. `make test` - All pass
3. `make format-check` - Properly formatted
4. `make generate` - If models/providers changed

## Agent Rules

1. **Stay in your lane** - Only modify files in your owned packages
2. **Run generate after model changes** - `make generate`
3. **Preserve public APIs** - Don't break exports without coordination
4. **Test your changes** - Add tests for new features
5. **Use existing patterns** - Follow established conventions
