class RouteStageEntity {
  final int stage;
  final String name;
  final String description;
  final double distanceKm;
  final double elevationGain;
  final String difficulty;
  final List<List<double>> coordinates;

  const RouteStageEntity({
    required this.stage,
    required this.name,
    required this.description,
    required this.distanceKm,
    required this.elevationGain,
    required this.difficulty,
    required this.coordinates,
  });

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedElevation => '${elevationGain.toStringAsFixed(0)} m';
}
