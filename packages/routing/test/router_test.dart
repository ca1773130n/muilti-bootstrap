import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routing/routing.dart';

void main() {
  test('routerProvider returns GoRouter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    final uri = router.routeInformationProvider.value.uri;
    expect(uri.path, RoutePaths.splash);
  });
}
