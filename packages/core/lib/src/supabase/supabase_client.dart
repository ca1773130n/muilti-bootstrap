import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

part 'supabase_client.g.dart';

/// Provides the Supabase client instance.
/// Must be initialized before use via [initializeSupabase].
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Provides the Supabase GoTrue client for auth operations.
@riverpod
GoTrueClient supabaseAuth(Ref ref) {
  return ref.watch(supabaseClientProvider).auth;
}

/// Initialize Supabase. Call this in main() before runApp().
Future<void> initializeSupabase() async {
  if (!Env.hasSupabaseConfig) {
    // Skip initialization if not configured (useful for mock mode)
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    debug: Env.enableLogging,
  );
}
