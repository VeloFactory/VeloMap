import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/services/map_controller.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/map_layers_sheet.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/routes_bottom_sheet.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/routes_search_bar.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final DraggableScrollableController _sheet = DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final MapController _mapController = MapController();
  ScrollController? _listScrollController;
  bool _isSearchVisible = false;
  List<RouteEntity>?
  _lastDisplayedRoutes; // Track last displayed routes for camera behavior
  RouteEntity?
  _previousSelectedRoute; // Track previous selection for clear behavior
  String _previousSearchQuery =
      ''; // Track previous search query for camera behavior
  double _currentSheetSize = _min;
  double _mapBearing = 0.0;

  // POI layer configuration
  MapLayerConfig _layerConfig = const MapLayerConfig();

  static const double _min = 0.105;
  static const double _mid = 0.45;
  static const double _max = 0.92;

  final snapSizes = <double>[_min, _mid, _max];

  @override
  void initState() {
    super.initState();
    _sheet.addListener(_onSheetPositionChanged);
    _requestLocationPermission();
  }

  void _onSheetPositionChanged() {
    if (!_sheet.isAttached) return;
    final newSize = _sheet.size;
    if (newSize != _currentSheetSize) {
      setState(() {
        _currentSheetSize = newSize;
      });
    }
  }

  @override
  void dispose() {
    _sheet.removeListener(_onSheetPositionChanged);
    _sheet.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchFocusNode.requestFocus();
        // Collapse sheet to mid if it's maximized
        if (_sheet.isAttached && _sheet.size > _mid) {
          _sheet.animateTo(
            _mid,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<RoutesBloc>().add(const RoutesEvent.clearSearch());
      }
    });
  }

  void _onSearchChanged(String query) {
    final bloc = context.read<RoutesBloc>();
    // Clear any route/stage selection when searching - user wants to see filtered list
    if (bloc.state.selectedRoute != null) {
      bloc.add(const RoutesEvent.clearSelection());
    }
    bloc.add(RoutesEvent.search(query));
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    _mapController.setLocationPermissionGranted(status.isGranted);
    setState(() {});

    if (status.isGranted && _mapController.mapboxMap != null) {
      await _enableUserLocation();
    }
  }

  Future<void> _enableUserLocation() async {
    if (_mapController.mapboxMap == null ||
        !_mapController.locationPermissionGranted) {
      return;
    }

    // Enable the location component with puck
    final locationSettings = _mapController.mapboxMap!.location;
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

  /// Called once when Mapbox map finishes initializing.
  ///
  /// NOTE: We call updateMapDisplay here AND in the BlocConsumer listener.
  /// This is intentional because:
  /// - _onMapCreated: Handles case when BLoC state loaded BEFORE map was ready
  /// - listener: Handles all state changes AFTER map is ready
  ///
  /// The MapController's operation ID mechanism prevents duplicate draws if both
  /// fire close together - the stale operation will detect a newer ID and exit early.
  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapController.setMapboxMap(mapboxMap);

    // Configure map settings (disable native compass, we use Flutter widget instead)
    await _mapController.configureMapSettings();

    // Create polyline annotation manager for drawing routes
    final polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _mapController.setPolylineManager(polylineManager);
    _mapController.setRouteTapHandler(_onRouteTapped);

    // Create point annotation manager for status markers
    final pointManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    _mapController.setPointManager(pointManager);

    if (!mounted) return;

    // Draw routes based on current BLoC state (may already have loaded data)
    final state = context.read<RoutesBloc>().state;

    if (state.selectedStage != null && state.selectedRoute != null) {
      // Stage is selected - show only that stage
      await _mapController.updateMapDisplay(
        mode: MapDisplayMode.singleStage,
        selectedRoute: state.selectedRoute,
        selectedStage: state.selectedStage,
      );
    } else if (state.selectedRoute != null) {
      // Route is selected - show only that route
      await _mapController.updateMapDisplay(
        mode: MapDisplayMode.singleRoute,
        selectedRoute: state.selectedRoute,
      );
    } else if (state.routes.isNotEmpty) {
      // No selection - show all routes
      await _mapController.updateMapDisplay(
        mode: MapDisplayMode.allRoutes,
        allRoutes: state.routes,
      );
      _lastDisplayedRoutes = state.routes;
    }

    // Enable user location if permission already granted
    if (_mapController.locationPermissionGranted) {
      await _enableUserLocation();
      if (state.routes.isEmpty) {
        await _mapController.moveToCurrentLocation();
      }
    }
  }

  void _onRouteTapped(String routeId) {
    final routes = context.read<RoutesBloc>().state.routes;
    final route = routes.where((r) => r.id == routeId).firstOrNull;
    if (route != null) {
      context.read<RoutesBloc>().add(RoutesEvent.selectRoute(route));
    }
  }

  void _showLayersDialog() {
    MapLayersSheet.show(
      context: context,
      config: _layerConfig,
      onConfigChanged: (newConfig) {
        setState(() {
          _layerConfig = newConfig;
        });
        // TODO: Apply layers to map
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<RoutesBloc, RoutesState>(
      listenWhen: (previous, current) =>
          previous.routes != current.routes ||
          previous.selectedRoute != current.selectedRoute ||
          previous.selectedStage != current.selectedStage ||
          previous.searchQuery !=
              current.searchQuery, // Listen to search changes
      // NOTE: This listener also calls updateMapDisplay (see _onMapCreated doc comment).
      // This handles all state changes AFTER the map is ready.
      listener: (context, state) {
        // Capture previous state before updating
        final wasViewingRoute = _previousSelectedRoute != null;
        final searchChanged = _previousSearchQuery != state.searchQuery;

        if (state.selectedStage != null && state.selectedRoute != null) {
          // Stage is selected - show only that stage
          _mapController.updateMapDisplay(
            mode: MapDisplayMode.singleStage,
            selectedRoute: state.selectedRoute,
            selectedStage: state.selectedStage,
          );
          _previousSelectedRoute = state.selectedRoute;
          _previousSearchQuery = state.searchQuery;
          // Expand sheet to show route details
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _mid,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        } else if (state.selectedRoute != null) {
          // Route is selected - show only that route
          _mapController.updateMapDisplay(
            mode: MapDisplayMode.singleRoute,
            selectedRoute: state.selectedRoute,
          );
          _previousSelectedRoute = state.selectedRoute;
          _previousSearchQuery = state.searchQuery;
          // Expand sheet to show route details
          if (_sheet.isAttached) {
            _sheet.animateTo(
              _mid,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
          // Scroll list to top to show selected route
          if (_listScrollController != null &&
              _listScrollController!.hasClients) {
            _listScrollController!.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        } else {
          // No selection - show filtered routes (or all if no search)
          final routesToDisplay = state.filteredRoutes;

          // Fit camera when:
          // 1. User cleared selection (was viewing a route/stage, now viewing list)
          // 2. Search query changed (show filtered results)
          // 3. Routes list changed (new data loaded)
          final routesChanged = _lastDisplayedRoutes != routesToDisplay;
          final shouldFitCamera =
              wasViewingRoute || searchChanged || routesChanged;

          if (routesToDisplay.isNotEmpty) {
            _mapController.updateMapDisplay(
              mode: MapDisplayMode.allRoutes,
              allRoutes: routesToDisplay,
              fitCamera: shouldFitCamera,
            );
            _lastDisplayedRoutes = routesToDisplay;
          } else {
            _mapController.updateMapDisplay(
              mode: MapDisplayMode.empty,
              fitCamera: false,
            );
          }
          _previousSelectedRoute = null;
          _previousSearchQuery = state.searchQuery;
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
                onCameraChangeListener: (cameraChangedEventData) {
                  // Track bearing for compass visibility
                  final bearing = cameraChangedEventData.cameraState.bearing;
                  if (bearing != _mapBearing) {
                    setState(() {
                      _mapBearing = bearing;
                    });
                  }
                },
                cameraOptions: CameraOptions(
                  center: MapController.defaultCenter,
                  zoom: MapController.defaultZoom,
                ),
              ),

              // Map control buttons - right side, bound to bottom sheet position
              // Hide when sheet is maximized (> 90%)
              if (_currentSheetSize < 0.9)
                Positioned(
                  right: 16,
                  bottom:
                      MediaQuery.of(context).size.height * _currentSheetSize +
                      16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compass button - only show when map is rotated (not aligned to north)
                      if (_mapBearing.abs() > 1.0) ...[
                        FloatingActionButton.small(
                          heroTag: 'compass_fab',
                          onPressed: _mapController.resetBearing,
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          elevation: 2,
                          child: Transform.rotate(
                            angle: -_mapBearing * (3.14159265359 / 180),
                            child: const Icon(Icons.navigation_rounded),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Layers button
                      FloatingActionButton.small(
                        heroTag: 'layers_fab',
                        onPressed: _showLayersDialog,
                        backgroundColor: colorScheme.surface,
                        foregroundColor: _layerConfig.hasActiveLayers
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        elevation: 2,
                        child: const Icon(Icons.place),
                      ),
                      const SizedBox(height: 8),
                      // Location button
                      FloatingActionButton.small(
                        heroTag: 'location_fab',
                        onPressed: _mapController.goToUserLocation,
                        backgroundColor: colorScheme.surface,
                        foregroundColor:
                            _mapController.locationPermissionGranted
                            ? colorScheme.primary
                            : colorScheme.outline,
                        elevation: 2,
                        child: Icon(
                          _mapController.locationPermissionGranted
                              ? Icons.my_location_rounded
                              : Icons.location_disabled_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

              // Search overlay at top of screen
              if (_isSearchVisible)
                RoutesSearchBar(
                  routes: state.routes,
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSearchChanged: _onSearchChanged,
                  onClose: _toggleSearch,
                  onSuggestionSelected: (city) {
                    _onSearchChanged(city);
                    setState(() {
                      _isSearchVisible = false;
                      _searchFocusNode.unfocus();
                    });
                  },
                ),

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
                  // Store reference to scroll controller for scrolling to top
                  _listScrollController = scrollController;
                  return RoutesBottomSheet(
                    controller: _sheet,
                    scrollController: scrollController,
                    state: state,
                    onSearchPressed: _toggleSearch,
                    minSize: _min,
                    midSize: _mid,
                    maxSize: _max,
                    snapSizes: snapSizes,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
