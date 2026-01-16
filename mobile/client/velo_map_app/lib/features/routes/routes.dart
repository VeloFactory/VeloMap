import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/route_list_tile.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final DraggableScrollableController _sheet = DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  bool _locationPermissionGranted = false;
  bool _isSearchVisible = false;

  static const double _min = 0.108;
  static const double _mid = 0.40;
  static const double _max = 0.96;

  final snapSizes = <double>[_min, _mid, _max];

  // Default camera position (Tel Aviv area)
  static final _defaultCenter = Point(coordinates: Position(34.78, 32.08));
  static const _defaultZoom = 11.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _sheet.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<RoutesBloc>().add(const RoutesEvent.clearSearch());
      }
    });
  }

  void _onSearchChanged(String query) {
    context.read<RoutesBloc>().add(RoutesEvent.search(query));
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    setState(() {
      _locationPermissionGranted = status.isGranted;
    });

    if (status.isGranted && _mapboxMap != null) {
      await _enableUserLocation();
    }
  }

  Future<void> _enableUserLocation() async {
    if (_mapboxMap == null || !_locationPermissionGranted) return;

    // Enable the location component with puck
    final locationSettings = _mapboxMap!.location;
    await locationSettings.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: Theme.of(context).colorScheme.primary.toARGB32(),
        showAccuracyRing: true,
        puckBearingEnabled: true,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Get screen height before async operations
    final screenHeight = MediaQuery.of(context).size.height;

    // Disable scale bar
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Configure compass - position it 10px above location button
    // Location button is at: (screenHeight * _mid + 16) from bottom
    // Location button height: 40px (FloatingActionButton.small)
    // Compass should be 10px above that
    final bottomSheetMidHeight = screenHeight * _mid;
    final locationButtonBottom = bottomSheetMidHeight + 16; // 16px margin above sheet at mid height
    final compassBottom = locationButtonBottom + 40 + 10; // 40px button + 10px spacing
    
    await mapboxMap.compass.updateSettings(CompassSettings(
      enabled: true,
      position: OrnamentPosition.BOTTOM_RIGHT,
      marginBottom: compassBottom,
      marginRight: 16,
    ));

    // Create polyline annotation manager for drawing routes
    _polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();

    // Enable user location if permission already granted
    if (_locationPermissionGranted) {
      await _enableUserLocation();
      await _moveToCurrentLocation();
    }
  }

  /// Move camera to current location if available (no animation, used at startup)
  Future<void> _moveToCurrentLocation() async {
    if (_mapboxMap == null) return;

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: geo.LocationSettings(
          accuracy: geo.LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        ),
      );
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: _defaultZoom,
        ),
      );
    } catch (_) {
      // Location unavailable - keep default Tel Aviv position
    }
  }

  Future<void> _drawRoute(RouteEntity route) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    // Clear existing annotations
    await _polylineManager!.deleteAll();

    // Convert coordinates to Position list
    final positions = route.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Create polyline annotation
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 5.0,
      lineOpacity: 0.9,
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to route bounds
    await _fitCameraToBounds(route);
  }

  Future<void> _drawStage(RouteStageEntity stage) async {
    if (_polylineManager == null || _mapboxMap == null) return;

    // Clear existing annotations
    await _polylineManager!.deleteAll();

    // Convert coordinates to Position list
    final positions = stage.coordinates
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    // Create polyline annotation with different color for stage
    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positions),
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 6.0,
      lineOpacity: 1.0,
    );

    await _polylineManager!.create(polylineOptions);

    // Fit camera to stage bounds
    await _fitCameraToStageBounds(stage);
  }

  Future<void> _fitCameraToStageBounds(RouteStageEntity stage) async {
    if (_mapboxMap == null || stage.coordinates.isEmpty) return;

    // Calculate bounding box for stage
    double minLng = stage.coordinates.first[0];
    double maxLng = stage.coordinates.first[0];
    double minLat = stage.coordinates.first[1];
    double maxLat = stage.coordinates.first[1];

    for (final coord in stage.coordinates) {
      if (coord[0] < minLng) minLng = coord[0];
      if (coord[0] > maxLng) maxLng = coord[0];
      if (coord[1] < minLat) minLat = coord[1];
      if (coord[1] > maxLat) maxLat = coord[1];
    }

    final padding = 80.0;

    // Create camera bounds
    final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: Point(coordinates: Position(minLng, minLat)),
        northeast: Point(coordinates: Position(maxLng, maxLat)),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(
        top: padding,
        left: padding,
        bottom: padding + 200,
        right: padding,
      ),
      null,
      null,
      null,
      null,
    );

    await _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
  }

  Future<void> _fitCameraToBounds(RouteEntity route) async {
    if (_mapboxMap == null) return;

    final bbox = route.boundingBox;
    final padding = 80.0;

    // Create camera bounds
    final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: Point(coordinates: Position(bbox[0], bbox[1])),
        northeast: Point(coordinates: Position(bbox[2], bbox[3])),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(
        top: padding,
        left: padding,
        bottom: padding + 200,
        right: padding,
      ),
      null,
      null,
      null,
      null,
    );

    await _mapboxMap!.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
  }

  Future<void> _clearRoute() async {
    if (_polylineManager == null) return;
    await _polylineManager!.deleteAll();

    // Return to user's location, or default if unavailable
    if (_mapboxMap != null) {
      if (_locationPermissionGranted) {
        try {
          // First try last known position (instant, no waiting)
          final lastPosition = await geo.Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            await _mapboxMap!.flyTo(
              CameraOptions(
                center: Point(
                  coordinates: Position(lastPosition.longitude, lastPosition.latitude),
                ),
                zoom: _defaultZoom,
              ),
              MapAnimationOptions(duration: 500),
            );
            return;
          }
          
          // If no last known, try current position with short timeout
          final position = await geo.Geolocator.getCurrentPosition(
            locationSettings: geo.LocationSettings(
              accuracy: geo.LocationAccuracy.low,
              timeLimit: const Duration(seconds: 2),
            ),
          );
          await _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(position.longitude, position.latitude),
              ),
              zoom: _defaultZoom,
            ),
            MapAnimationOptions(duration: 500),
          );
          return;
        } catch (_) {
          // Fall through to default location
        }
      }
      
      // Fallback to default location if current location unavailable
      await _mapboxMap!.flyTo(
        CameraOptions(center: _defaultCenter, zoom: _defaultZoom),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  Future<void> _goToUserLocation() async {
    if (_mapboxMap == null || !_locationPermissionGranted) {
      // Request permission if not granted
      await _requestLocationPermission();
      return;
    }

    try {
      // Get current position using Geolocator
      final position = await geo.Geolocator.getCurrentPosition();

      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 800),
      );
    } catch (e) {
      // If getting current position fails, try last known position
      final lastPosition = await geo.Geolocator.getLastKnownPosition();
      if (lastPosition != null && _mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                lastPosition.longitude,
                lastPosition.latitude,
              ),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 800),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<RoutesBloc, RoutesState>(
      listener: (context, state) {
        if (state.selectedRoute != null) {
          // If a stage is selected, draw only that stage; otherwise draw full route
          if (state.selectedStage != null) {
            _drawStage(state.selectedStage!);
          } else {
            _drawRoute(state.selectedRoute!);
          }
          // Expand sheet to show route details
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _max,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        } else {
          _clearRoute();
          // Collapse sheet when no route selected
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _mid,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          // Prevent keyboard from pushing UI up when search is active
          resizeToAvoidBottomInset: !_isSearchVisible,
          body: Stack(
            children: [
              // Map
              MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: _onMapCreated,
                cameraOptions: CameraOptions(
                  center: _defaultCenter,
                  zoom: _defaultZoom,
                ),
              ),

              // Location button - right side, just above the bottom sheet at default (mid) height
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * _mid + 16,
                child: FloatingActionButton.small(
                  heroTag: 'location_fab',
                  onPressed: _goToUserLocation,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: _locationPermissionGranted
                      ? colorScheme.primary
                      : colorScheme.outline,
                  elevation: 2,
                  child: Icon(
                    _locationPermissionGranted
                        ? Icons.my_location_rounded
                        : Icons.location_disabled_rounded,
                  ),
                ),
              ),

              // Search overlay at top of screen
              if (_isSearchVisible)
                _buildSearchOverlay(context, state, colorScheme),

              // Loading indicator
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),

              // Bottom sheet with routes list
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: _min,
                minChildSize: _min,
                maxChildSize: _max,
                snap: true,
                snapSizes: snapSizes,
                builder: (context, scrollController) {
                  return _buildBottomSheet(
                    context,
                    scrollController,
                    state,
                    colorScheme,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -4),
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle + Header
          _buildSheetHeader(context, state, colorScheme),
          // Content
          Expanded(
            child: state.error != null
                ? _buildErrorView(state.error!, colorScheme)
                : state.routes.isEmpty && !state.isLoading
                ? _buildEmptyView(colorScheme)
                : _buildRoutesList(scrollController, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(
    BuildContext context,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (!_sheet.isAttached) return;
        final screenH = MediaQuery.of(context).size.height;
        final delta = -details.delta.dy / screenH;
        final next = (_sheet.size + delta).clamp(_min, _max).toDouble();
        _sheet.jumpTo(next);
      },
      onVerticalDragEnd: (_) {
        if (!_sheet.isAttached) return;
        final current = _sheet.size;
        double nearest = snapSizes.first;
        double bestDist = (current - nearest).abs();
        for (final s in snapSizes.skip(1)) {
          final d = (current - s).abs();
          if (d < bestDist) {
            bestDist = d;
            nearest = s;
          }
        }
        _sheet.animateTo(
          nearest,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          _buildTitleRow(context, state, colorScheme),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Get autocomplete suggestions based on search query
  List<String> _getAutocompleteSuggestions(RoutesState state) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];

    // Collect all unique cities from all routes
    final allCities = <String>{};
    for (final route in state.routes) {
      allCities.addAll(route.cities);
    }

    // Filter and limit suggestions
    return allCities
        .where((city) => city.toLowerCase().contains(query))
        .take(8)
        .toList()
      ..sort((a, b) {
        // Prioritize cities that start with the query
        final aStarts = a.toLowerCase().startsWith(query);
        final bStarts = b.toLowerCase().startsWith(query);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.compareTo(b);
      });
  }

  void _onSuggestionSelected(String city) {
    _searchController.text = city;
    _searchController.selection = TextSelection.collapsed(offset: city.length);
    _onSearchChanged(city);
    // Close the search bar after selecting a city
    setState(() {
      _isSearchVisible = false;
      _searchFocusNode.unfocus();
    });
  }

  Widget _buildSearchOverlay(
    BuildContext context,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    final suggestions = _getAutocompleteSuggestions(state);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: colorScheme.surface,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: _toggleSearch,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    // Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (query) {
                          _onSearchChanged(query);
                          setState(() {}); // Refresh suggestions
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search by city name...',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Autocomplete suggestions
              if (suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final city = suggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_city_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        title: _buildHighlightedText(
                          city,
                          _searchController.text,
                          colorScheme,
                        ),
                        onTap: () => _onSuggestionSelected(city),
                        dense: true,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text with the search query highlighted
  Widget _buildHighlightedText(
    String text,
    String query,
    ColorScheme colorScheme,
  ) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerText.indexOf(lowerQuery);

    if (matchStart < 0) return Text(text);

    final matchEnd = matchStart + query.length;
    return RichText(
      text: TextSpan(
        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
        children: [
          TextSpan(text: text.substring(0, matchStart)),
          TextSpan(
            text: text.substring(matchStart, matchEnd),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(text: text.substring(matchEnd)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    RoutesState state,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with search and clear buttons
          Row(
            children: [
              Icon(Icons.route_rounded, color: colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                'EuroVelo Routes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Search icon button
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Search by city',
              ),
              // Clear button (text only)
              if (state.selectedRoute != null)
                TextButton(
                  onPressed: () {
                    context.read<RoutesBloc>().add(
                      const RoutesEvent.clearSelection(),
                    );
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
            ],
          ),
          // Active filter chip - shown below title when search is active
          if (state.isSearchActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InputChip(
                label: Text(
                  state.searchQuery,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 13,
                  ),
                ),
                avatar: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                deleteIcon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                onDeleted: () {
                  _searchController.clear();
                  context.read<RoutesBloc>().add(const RoutesEvent.clearSearch());
                },
                onPressed: _toggleSearch,
                backgroundColor: colorScheme.secondaryContainer,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoutesList(
    ScrollController scrollController,
    RoutesState state,
  ) {
    // Use filteredRoutes for search, or all routes if no search
    final displayedRoutes = state.filteredRoutes;
    
    // Show "no results" if search is active but no matches
    if (state.isSearchActive && displayedRoutes.isEmpty) {
      return _buildNoSearchResultsView(Theme.of(context).colorScheme);
    }
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: displayedRoutes.length,
      itemBuilder: (context, index) {
        final route = displayedRoutes[index];
        final isSelected = state.selectedRoute?.id == route.id;

        return RouteListTile(
          route: route,
          isSelected: isSelected,
          selectedStage: isSelected ? state.selectedStage : null,
          onTap: () {
            if (isSelected) {
              context.read<RoutesBloc>().add(
                const RoutesEvent.clearSelection(),
              );
            } else {
              context.read<RoutesBloc>().add(RoutesEvent.selectRoute(route));
            }
          },
          onStageSelected: (stage) {
            context.read<RoutesBloc>().add(RoutesEvent.selectStage(stage));
          },
          onStageClear: () {
            context.read<RoutesBloc>().add(
              const RoutesEvent.clearStageSelection(),
            );
          },
        );
      },
    );
  }

  Widget _buildNoSearchResultsView(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No routes found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different city',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load routes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   error,
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: colorScheme.onSurfaceVariant,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 24),
            // FilledButton.icon(
            //   onPressed: () {
            //     context.read<RoutesBloc>().add(const RoutesEvent.load());
            //   },
            //   icon: const Icon(Icons.refresh_rounded),
            //   label: const Text('Retry'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No routes available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Routes will appear here once loaded',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
