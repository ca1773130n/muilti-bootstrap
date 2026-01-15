import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapStatusCodeToException maps known codes', () {
    expect(mapStatusCodeToException(401), isA<UnauthorizedException>());
    expect(mapStatusCodeToException(403), isA<ForbiddenException>());
    expect(mapStatusCodeToException(404), isA<NotFoundException>());
    expect(mapStatusCodeToException(500), isA<ServerException>());
  });
}
