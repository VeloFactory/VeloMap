class GeoPoint {
  /// [lat, lon]
  final List<double> coords;
  final double? elevation;

  const GeoPoint({required this.coords, this.elevation});

  double get lat => coords[0];
  double get lon => coords[1];

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
    coords: List<double>.from(
      (json['coords'] as List).map((e) => (e as num).toDouble()),
    ),
    elevation: (json['elevation'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'coords': coords,
    if (elevation != null) 'elevation': elevation,
  };
}
