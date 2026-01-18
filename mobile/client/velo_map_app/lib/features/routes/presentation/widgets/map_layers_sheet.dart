import 'package:flutter/material.dart';
import 'package:velo_map_app/features/routes/domain/models/map_layer_config.dart';

export 'package:velo_map_app/features/routes/domain/models/map_layer_config.dart';

/// Bottom sheet widget for selecting POI layers to display on the map
class MapLayersSheet extends StatelessWidget {
  final MapLayerConfig config;
  final ValueChanged<MapLayerConfig> onConfigChanged;

  const MapLayersSheet({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  /// Show the map layers sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required MapLayerConfig config,
    required ValueChanged<MapLayerConfig> onConfigChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          MapLayersSheet(config: config, onConfigChanged: onConfigChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.layers_rounded, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Map Layers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Show points of interest on the map',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Restaurants checkbox
            _LayerCheckbox(
              value: config.showRestaurants,
              onChanged: (value) {
                onConfigChanged(config.copyWith(showRestaurants: value));
              },
              title: 'Restaurants',
              subtitle: 'Cafes, restaurants, food places',
              icon: Icons.restaurant_rounded,
              colorScheme: colorScheme,
            ),

            // Hotels checkbox
            _LayerCheckbox(
              value: config.showHotels,
              onChanged: (value) {
                onConfigChanged(config.copyWith(showHotels: value));
              },
              title: 'Hotels',
              subtitle: 'Hotels, hostels, B&Bs',
              icon: Icons.hotel_rounded,
              colorScheme: colorScheme,
            ),

            // Camping checkbox
            _LayerCheckbox(
              value: config.showCamping,
              onChanged: (value) {
                onConfigChanged(config.copyWith(showCamping: value));
              },
              title: 'Camping',
              subtitle: 'Campsites, caravan parks',
              icon: Icons.cabin_rounded,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final IconData icon;
  final ColorScheme colorScheme;

  const _LayerCheckbox({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: colorScheme.primary),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
