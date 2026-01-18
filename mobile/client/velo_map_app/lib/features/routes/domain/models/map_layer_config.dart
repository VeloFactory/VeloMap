/// POI layer configuration for the map
class MapLayerConfig {
  final bool showRestaurants;
  final bool showHotels;
  final bool showCamping;

  const MapLayerConfig({
    this.showRestaurants = false,
    this.showHotels = false,
    this.showCamping = false,
  });

  MapLayerConfig copyWith({
    bool? showRestaurants,
    bool? showHotels,
    bool? showCamping,
  }) {
    return MapLayerConfig(
      showRestaurants: showRestaurants ?? this.showRestaurants,
      showHotels: showHotels ?? this.showHotels,
      showCamping: showCamping ?? this.showCamping,
    );
  }

  bool get hasActiveLayers => showRestaurants || showHotels || showCamping;
}
