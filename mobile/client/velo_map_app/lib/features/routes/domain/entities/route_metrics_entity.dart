class RouteMetricsEntity {
  final int distance;
  final int elevationGain;
  final int elevationLoss;
  final int? estimatedTimeMin;

  const RouteMetricsEntity({
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    this.estimatedTimeMin,
  });
}
