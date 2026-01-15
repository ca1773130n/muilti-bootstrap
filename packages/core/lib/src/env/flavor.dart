enum Flavor {
  dev,
  stage,
  prod,
}

Flavor flavorFromString(String value) {
  return Flavor.values.firstWhere(
    (f) => f.name == value.toLowerCase(),
    orElse: () => Flavor.dev,
  );
}
