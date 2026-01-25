import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:routing/routing.dart';

void main() {
  setUpAll(() {
    // Initialize Env before tests run
    Env.initialize(
      flavorValue: 'dev',
      apiBaseUrlValue: 'http://localhost:8000',
      appNameValue: 'Test App',
    );
  });

  test('routerProvider returns GoRouter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    final uri = router.routeInformationProvider.value.uri;
    expect(uri.path, RoutePaths.splash);
  });
}
