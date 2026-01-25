import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:routing/routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.initialize(
    flavorValue: const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
    apiBaseUrlValue: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000',
    ),
    appNameValue: const String.fromEnvironment(
      'APP_NAME',
      defaultValue: 'MyApp',
    ),
    enableLoggingValue: const String.fromEnvironment('ENABLE_LOGGING'),
    supabaseUrlValue: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKeyValue: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Initialize Supabase if configured
  await initializeSupabase();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: Env.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: Env.isDev,
    );
  }
}
