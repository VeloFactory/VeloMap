import 'dart:collection';

import 'package:velo_map_app/features/route_planner/domain/entities/route_plan_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

/// Builds a graph of EuroVelo routes connected by shared cities,
/// then uses BFS to find the shortest route path between any two cities.
///
/// Initialized lazily after routes are loaded — call [initialize] once.
class RoutePlannerService {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// All known city names (for autocomplete)
  List<String> _allCities = [];
  List<String> get allCities => _allCities;

  // city (lowercase) → list of route IDs that include this city
  final Map<String, List<String>> _cityToRouteIds = {};

  // route ID → RouteEntity
  final Map<String, RouteEntity> _routeById = {};

  // route ID → list of (neighborRouteId, sharedCity)
  final Map<String, List<_RouteEdge>> _routeGraph = {};

  // city (lowercase) → original display name
  final Map<String, String> _cityDisplayName = {};

  void initialize(List<RouteEntity> routes) {
    if (_isInitialized) return;

    _routeById.clear();
    _cityToRouteIds.clear();
    _routeGraph.clear();
    _cityDisplayName.clear();

    // 1. Build city → routes index
    for (final route in routes) {
      _routeById[route.id] = route;
      for (final city in route.cities) {
        final key = city.toLowerCase();
        _cityDisplayName[key] = city;
        _cityToRouteIds.putIfAbsent(key, () => []).add(route.id);
      }
    }

    // 2. Build route graph (routes connected by shared cities)
    for (final entry in _cityToRouteIds.entries) {
      final city = entry.key;
      final routeList = entry.value;
      if (routeList.length < 2) continue;

      for (int i = 0; i < routeList.length; i++) {
        for (int j = i + 1; j < routeList.length; j++) {
          final r1 = routeList[i];
          final r2 = routeList[j];
          _routeGraph.putIfAbsent(r1, () => []).add(_RouteEdge(r2, city));
          _routeGraph.putIfAbsent(r2, () => []).add(_RouteEdge(r1, city));
        }
      }
    }

    // 3. Collect unique city names for autocomplete
    _allCities = _cityDisplayName.values.toList()..sort();

    _isInitialized = true;
  }

  /// Find route plan variants from [startCity] to [endCity].
  /// Returns empty list if no path exists.
  List<RoutePlanVariant> findRoute(String startCity, String endCity) {
    if (!_isInitialized) return [];

    final startKey = startCity.toLowerCase();
    final endKey = endCity.toLowerCase();

    if (startKey == endKey) return [];

    final startRoutes = _cityToRouteIds[startKey];
    final endRoutes = _cityToRouteIds[endKey];
    if (startRoutes == null || endRoutes == null) return [];

    final endRouteSet = endRoutes.toSet();

    // BFS on route graph to find shortest route path
    final routePath = _bfsRoutes(startRoutes, endRouteSet);
    if (routePath == null) return [];

    // Expand route path into concrete city-by-city variants
    return _expandRoutePath(routePath, startKey, endKey);
  }

  /// BFS: find shortest sequence of routes from any start route to any end route
  List<String>? _bfsRoutes(List<String> startRoutes, Set<String> endRoutes) {
    final queue = Queue<_BfsNode>();
    final visited = <String>{};

    for (final r in startRoutes) {
      queue.add(_BfsNode(r, [r]));
      visited.add(r);
    }

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();

      if (endRoutes.contains(node.routeId)) {
        return node.path;
      }

      final edges = _routeGraph[node.routeId];
      if (edges == null) continue;

      for (final edge in edges) {
        if (!visited.contains(edge.routeId)) {
          visited.add(edge.routeId);
          queue.add(_BfsNode(edge.routeId, [...node.path, edge.routeId]));
        }
      }
    }

    return null;
  }

  /// Expand a route path into concrete variants with transfer city choices
  List<RoutePlanVariant> _expandRoutePath(
    List<String> routePath,
    String startCityKey,
    String endCityKey,
  ) {
    final variants = <RoutePlanVariant>[];

    if (routePath.length == 1) {
      // Direct route — single segment
      final route = _routeById[routePath[0]]!;
      final segment = _buildSegment(route, startCityKey, endCityKey);
      if (segment != null) {
        variants.add(RoutePlanVariant(segments: [segment]));
      }
      return variants;
    }

    // Multiple routes — find transfer cities and build variants via DFS
    _dfsExpand(
      routePath: routePath,
      routeIndex: 0,
      currentCityKey: startCityKey,
      endCityKey: endCityKey,
      currentSegments: [],
      variants: variants,
    );

    return variants;
  }

  void _dfsExpand({
    required List<String> routePath,
    required int routeIndex,
    required String currentCityKey,
    required String endCityKey,
    required List<RoutePlanSegment> currentSegments,
    required List<RoutePlanVariant> variants,
  }) {
    if (routeIndex == routePath.length - 1) {
      // Last route — go from current city to end city
      final route = _routeById[routePath[routeIndex]]!;
      final segment = _buildSegment(route, currentCityKey, endCityKey);
      if (segment != null) {
        variants.add(RoutePlanVariant(
          segments: [...currentSegments, segment],
        ));
      }
      return;
    }

    final currentRouteId = routePath[routeIndex];
    final nextRouteId = routePath[routeIndex + 1];
    final currentRoute = _routeById[currentRouteId]!;

    // Find shared cities between current route and next route
    final transferCities = _sharedCities(currentRouteId, nextRouteId);

    for (final transferCityKey in transferCities) {
      // Don't transfer at the start city (no progress)
      if (transferCityKey == currentCityKey) continue;

      final segment = _buildSegment(currentRoute, currentCityKey, transferCityKey);
      if (segment == null) continue;

      _dfsExpand(
        routePath: routePath,
        routeIndex: routeIndex + 1,
        currentCityKey: transferCityKey,
        endCityKey: endCityKey,
        currentSegments: [...currentSegments, segment],
        variants: variants,
      );
    }
  }

  /// Cities shared between two routes (lowercase keys)
  List<String> _sharedCities(String routeId1, String routeId2) {
    final route1 = _routeById[routeId1]!;
    final route2Cities = _routeById[routeId2]!.cities.map((c) => c.toLowerCase()).toSet();
    return route1.cities
        .map((c) => c.toLowerCase())
        .where((c) => route2Cities.contains(c))
        .toList();
  }

  /// Build a RoutePlanSegment for traveling on [route] from [fromKey] to [toKey].
  ///
  /// Uses stage *name* matching rather than the `cities` list index, because
  /// the collection-level `cities` array can contain MORE entries than
  /// `stages.length + 1` (multi-waypoint stage names add extra intermediate
  /// cities that break the simple `cities[i] == departure of stages[i]`
  /// invariant).
  RoutePlanSegment? _buildSegment(
    RouteEntity route,
    String fromKey,
    String toKey,
  ) {
    int fromStageIdx = -1; // first stage whose departure == fromKey
    int toStageIdx = -1; // last stage whose destination == toKey

    for (int i = 0; i < route.stages.length; i++) {
      final parts = _splitStageName(route.stages[i].name);
      if (parts.isEmpty) continue;
      final dep = _normCity(parts.first);
      final dest = parts.length >= 2 ? _normCity(parts.last) : '';

      if (dep == fromKey && fromStageIdx < 0) {
        fromStageIdx = i;
      }
      if (dest.isNotEmpty && dest == toKey) {
        toStageIdx = i;
      }
    }

    if (fromStageIdx < 0 || toStageIdx < 0 || fromStageIdx == toStageIdx) {
      return null;
    }

    final reversed = fromStageIdx > toStageIdx;
    final startIdx = reversed ? toStageIdx : fromStageIdx;
    final endIdx = reversed ? fromStageIdx : toStageIdx;

    // Collect stages [startIdx..endIdx] inclusive
    final segmentStages = <RouteStageEntity>[];
    final segmentCoords = <List<double>>[];

    for (int i = startIdx; i <= endIdx; i++) {
      segmentStages.add(route.stages[i]);
      segmentCoords.addAll(route.stages[i].coordinates);
    }

    if (segmentStages.isEmpty) return null;

    // Build ordered city list from the stage names (avoids duplicates at
    // stage boundaries where dest of stage N == departure of stage N+1).
    final segmentCities = <String>[];
    for (final stage in segmentStages) {
      final parts = _splitStageName(stage.name);
      if (parts.isEmpty) continue;
      if (segmentCities.isEmpty) {
        segmentCities.addAll(parts);
      } else {
        // First part is the same as the last city already added — skip it.
        for (int j = 1; j < parts.length; j++) {
          segmentCities.add(parts[j]);
        }
      }
    }

    if (reversed) {
      return RoutePlanSegment(
        route: route,
        fromCity: _cityDisplayName[fromKey] ?? fromKey,
        toCity: _cityDisplayName[toKey] ?? toKey,
        cities: segmentCities.reversed.toList(),
        stages: segmentStages.reversed.toList(),
        coordinates: segmentCoords.reversed.toList(),
      );
    }

    return RoutePlanSegment(
      route: route,
      fromCity: _cityDisplayName[fromKey] ?? fromKey,
      toCity: _cityDisplayName[toKey] ?? toKey,
      cities: segmentCities,
      stages: segmentStages,
      coordinates: segmentCoords,
    );
  }

  /// Split a stage name like "Nordkapp – Honningsvåg" into city parts.
  /// Handles en-dash (–, U+2013), em-dash (—, U+2014), minus (−, U+2212)
  /// and plain ASCII hyphen (-) surrounded by spaces on at least one side.
  static List<String> _splitStageName(String name) {
    // Remove trailing parenthetical like "(DEVELOPED_WITH_SIGNS)"
    final cleaned =
        name.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();
    // Split on any dash variant (-, –, —, −) with whitespace on at least one side
    return cleaned
        .split(RegExp(r'\s+[-–—−]\s*|\s*[-–—−]\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Normalize a city name to ASCII lowercase so that accented variants
  /// (e.g. "Honningsvåg") match the stored normalized key ("honningsvag").
  /// Mirrors the Python `normalize_city_name` used when generating GeoJSON.
  static String _normCity(String name) {
    const accents = <String, String>{
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'æ': 'ae',
      'ç': 'c', 'č': 'c', 'ć': 'c',
      'ď': 'd', 'đ': 'd',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ě': 'e',
      'ğ': 'g',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ı': 'i',
      'ł': 'l',
      'ñ': 'n', 'ń': 'n', 'ň': 'n',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ő': 'o', 'ø': 'o',
      'ř': 'r',
      'ß': 'ss', 'š': 's', 'ş': 's', 'ś': 's',
      'ș': 's',
      'ț': 't', 'ť': 't',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ű': 'u', 'ů': 'u',
      'ý': 'y', 'ÿ': 'y',
      'ž': 'z', 'ź': 'z', 'ż': 'z',
      'ą': 'a', 'ă': 'a',
      'ę': 'e',
    };
    final buf = StringBuffer();
    for (final rune in name.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buf.write(accents[ch] ?? ch);
    }
    return buf.toString();
  }
}

class _RouteEdge {
  final String routeId;
  final String city; // lowercase key of shared city

  const _RouteEdge(this.routeId, this.city);
}

class _BfsNode {
  final String routeId;
  final List<String> path;

  const _BfsNode(this.routeId, this.path);
}