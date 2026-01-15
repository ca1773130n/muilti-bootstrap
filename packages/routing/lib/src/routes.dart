import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

final List<RouteBase> appRoutes = [
  GoRoute(
    path: RoutePaths.splash,
    name: RouteNames.splash,
    builder: (context, state) => const SplashPage(),
  ),
  GoRoute(
    path: RoutePaths.home,
    name: RouteNames.home,
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: RoutePaths.login,
    name: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: RoutePaths.register,
    name: RouteNames.register,
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    path: RoutePaths.profile,
    name: RouteNames.profile,
    builder: (context, state) => const ProfilePage(),
  ),
  GoRoute(
    path: RoutePaths.settings,
    name: RouteNames.settings,
    builder: (context, state) => const SettingsPage(),
  ),
];

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.goNamed(RouteNames.home);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.pushNamed(RouteNames.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to MyApp!')),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(RouteNames.home),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => context.goNamed(RouteNames.register),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(RouteNames.home),
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () => context.goNamed(RouteNames.login),
              child: const Text('Already have an account?'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}
