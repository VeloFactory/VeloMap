class RouteMetrics {
  final int distance;
  final int elevationGain;
  final int elevationLoss;
  final int? estimatedTimeMin;

  const RouteMetrics({
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    this.estimatedTimeMin,
  });
}
