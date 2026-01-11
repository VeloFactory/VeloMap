class GeoPoint {
  final double lat;
  final double lng;
  final double? elevation;

  const GeoPoint({required this.lat, required this.lng, this.elevation});
}
