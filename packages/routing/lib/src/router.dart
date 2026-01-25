import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:auth/auth.dart';

import 'route_names.dart';
import 'routes.dart';

part 'router.g.dart';

/// Routes that require authentication.
const _protectedRoutes = [
  RoutePaths.profile,
  RoutePaths.settings,
];

/// Routes that are only for unauthenticated users.
const _authRoutes = [
  RoutePaths.login,
  RoutePaths.register,
];

@riverpod
GoRouter router(Ref ref) {
  // Watch auth state for reactive redirects
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: appRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isLoading = authState.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      );

      // Don't redirect while loading auth state
      if (isLoading) {
        return null;
      }

      // Check if trying to access protected route
      final isProtectedRoute = _protectedRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      // Check if trying to access auth route (login/register)
      final isAuthRoute = _authRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      // Redirect unauthenticated users from protected routes to login
      if (isProtectedRoute && !isAuthenticated) {
        return RoutePaths.login;
      }

      // Redirect authenticated users from auth routes to home
      if (isAuthRoute && isAuthenticated) {
        return RoutePaths.home;
      }

      // Redirect from splash based on auth state
      if (currentPath == RoutePaths.splash) {
        return isAuthenticated ? RoutePaths.home : RoutePaths.login;
      }

      return null;
    },
  );
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
