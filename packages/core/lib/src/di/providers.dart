import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderContainer createProviderContainer({
  List<Override>? overrides,
  List<ProviderObserver>? observers,
}) {
  return ProviderContainer(
    overrides: overrides ?? [],
    observers: observers ?? [],
  );
}
