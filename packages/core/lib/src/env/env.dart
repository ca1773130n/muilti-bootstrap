import 'flavor.dart';

class Env {
  Env._();

  static late final Flavor flavor;
  static late final String apiBaseUrl;
  static late final String appName;
  static late final bool enableLogging;

  static void initialize({
    required String flavorValue,
    required String apiBaseUrlValue,
    required String appNameValue,
    String? enableLoggingValue,
  }) {
    flavor = flavorFromString(flavorValue);
    apiBaseUrl = apiBaseUrlValue;
    appName = appNameValue;
    enableLogging = enableLoggingValue?.toLowerCase() == 'true' || flavor == Flavor.dev;
  }

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStage => flavor == Flavor.stage;
  static bool get isProd => flavor == Flavor.prod;
}
