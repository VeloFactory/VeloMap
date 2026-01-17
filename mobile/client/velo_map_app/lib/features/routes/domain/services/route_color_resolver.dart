class RouteColorResolver {
  const RouteColorResolver();

  static const List<int> _palette = [
    0xFF1E88E5,
    0xFF1565C0,
    0xFF42A5F5,
    0xFF3949AB,
    0xFF283593,
    0xFF0277BD,

    0xFF43A047,
    0xFF2E7D32,
    0xFF00897B,
    0xFF00796B,

    0xFF5E35B1,
    0xFF4527A0,

    0xFFF4511E,
    0xFFE53935,
    0xFFD81B60,

    0xFF6D4C41,
    0xFF546E7A,
  ];

  static const Map<String, int> _overrides = {
    // Add explicit route id overrides here if needed.
  };

  int resolve({required String id, required int routeNumber}) {
    final normalizedId = id.trim().toLowerCase();
    final override = _overrides[normalizedId];
    if (override != null) return override;

    final base = routeNumber > 0 ? routeNumber : _hash(normalizedId);
    final index = base % _palette.length;
    return _palette[index];
  }

  int _hash(String value) {
    if (value.isEmpty) return 0;
    var hash = 0;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
