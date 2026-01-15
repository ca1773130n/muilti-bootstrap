import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  test('Env initializes values correctly', () {
    Env.initialize(
      flavorValue: 'dev',
      apiBaseUrlValue: 'https://example.com',
      appNameValue: 'TestApp',
      enableLoggingValue: 'true',
    );

    expect(Env.flavor, Flavor.dev);
    expect(Env.apiBaseUrl, 'https://example.com');
    expect(Env.appName, 'TestApp');
    expect(Env.enableLogging, true);
    expect(Env.isDev, true);
  });
}
