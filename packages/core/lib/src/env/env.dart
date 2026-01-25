import 'flavor.dart';

class Env {
  Env._();

  static late final Flavor flavor;
  static late final String apiBaseUrl;
  static late final String appName;
  static late final bool enableLogging;
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;

  static void initialize({
    required String flavorValue,
    required String apiBaseUrlValue,
    required String appNameValue,
    String? enableLoggingValue,
    String? supabaseUrlValue,
    String? supabaseAnonKeyValue,
  }) {
    flavor = flavorFromString(flavorValue);
    apiBaseUrl = apiBaseUrlValue;
    appName = appNameValue;
    enableLogging =
        enableLoggingValue?.toLowerCase() == 'true' || flavor == Flavor.dev;
    supabaseUrl = supabaseUrlValue ?? '';
    supabaseAnonKey = supabaseAnonKeyValue ?? '';
  }

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStage => flavor == Flavor.stage;
  static bool get isProd => flavor == Flavor.prod;

  /// Returns true if Supabase configuration is available.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
