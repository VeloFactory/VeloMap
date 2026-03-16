import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velo_map_app/features/route_planner/presentation/cubit/route_planner_cubit.dart';
import 'package:velo_map_app/features/route_planner/presentation/cubit/route_planner_state.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/services/search_manager.dart';

/// Search bar with autocomplete suggestions for city-based route search
/// and a toggle to switch to Route Planner mode (from → to).
class RoutesSearchBar extends StatefulWidget {
  final List<RouteEntity> routes;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClose;
  final ValueChanged<String> onSuggestionSelected;

  const RoutesSearchBar({
    super.key,
    required this.routes,
    required this.controller,
    required this.focusNode,
    required this.onSearchChanged,
    required this.onClose,
    required this.onSuggestionSelected,
  });

  @override
  State<RoutesSearchBar> createState() => _RoutesSearchBarState();
}

class _RoutesSearchBarState extends State<RoutesSearchBar>
    with TickerProviderStateMixin {
  final _searchManager = SearchManager();
  List<String> _suggestions = [];
  bool _showSearchBar = false;
  bool _closing = false;
  static const _closeDuration = Duration(milliseconds: 200);
  static const _openDuration = Duration(milliseconds: 240);

  // Route planner mode
  bool _isPlannerMode = false;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();
  _PlannerField _activePlannerField = _PlannerField.from;
  List<String> _plannerSuggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSuggestions);
    _fromController.addListener(_updatePlannerSuggestions);
    _toController.addListener(_updatePlannerSuggestions);
    _fromFocusNode.addListener(_onPlannerFocusChanged);
    _toFocusNode.addListener(_onPlannerFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showSearchBar = true);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSuggestions);
    _fromController.removeListener(_updatePlannerSuggestions);
    _toController.removeListener(_updatePlannerSuggestions);
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.removeListener(_onPlannerFocusChanged);
    _toFocusNode.removeListener(_onPlannerFocusChanged);
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _onPlannerFocusChanged() {
    if (_fromFocusNode.hasFocus) {
      setState(() => _activePlannerField = _PlannerField.from);
      _updatePlannerSuggestions();
    } else if (_toFocusNode.hasFocus) {
      setState(() => _activePlannerField = _PlannerField.to);
      _updatePlannerSuggestions();
    }
  }

  void _updateSuggestions() {
    setState(() {
      _suggestions = _searchManager.getAutocompleteSuggestions(
        widget.routes,
        widget.controller.text,
      );
    });
  }

  void _updatePlannerSuggestions() {
    final cubit = context.read<RoutePlannerCubit>();
    final query = _activePlannerField == _PlannerField.from
        ? _fromController.text
        : _toController.text;
    setState(() {
      _plannerSuggestions = cubit.getCitySuggestions(query);
    });
  }

  void _handleSuggestionTap(String city) {
    widget.controller.text = city;
    widget.controller.selection = TextSelection.collapsed(offset: city.length);
    widget.onSuggestionSelected(city);
  }

  void _handlePlannerSuggestionTap(String city) {
    final cubit = context.read<RoutePlannerCubit>();
    if (_activePlannerField == _PlannerField.from) {
      _fromController.text = city;
      _fromController.selection =
          TextSelection.collapsed(offset: city.length);
      cubit.setFromCity(city);
      // Move focus to the "to" field
      _toFocusNode.requestFocus();
    } else {
      _toController.text = city;
      _toController.selection =
          TextSelection.collapsed(offset: city.length);
      cubit.setToCity(city);
      // Unfocus so user can tap "Find Route"
      _toFocusNode.unfocus();
    }
    setState(() => _plannerSuggestions = []);
  }

  void _handleFindRoute() {
    final cubit = context.read<RoutePlannerCubit>();
    cubit.setFromCity(_fromController.text);
    cubit.setToCity(_toController.text);
    cubit.findRoute();
  }

  void _togglePlannerMode() {
    setState(() {
      _isPlannerMode = !_isPlannerMode;
      _plannerSuggestions = [];
      _suggestions = [];
      if (_isPlannerMode) {
        widget.focusNode.unfocus();
        _fromFocusNode.requestFocus();
      } else {
        _fromFocusNode.unfocus();
        _toFocusNode.unfocus();
        widget.focusNode.requestFocus();
      }
    });
  }

  void _swapCities() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
    final cubit = context.read<RoutePlannerCubit>();
    cubit.setFromCity(_fromController.text);
    cubit.setToCity(_toController.text);
  }

  Future<void> _handleClose() async {
    if (_closing) {
      return;
    }
    _closing = true;
    setState(() => _showSearchBar = false);
    await Future.delayed(_closeDuration);
    if (mounted) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: _showSearchBar ? Offset.zero : const Offset(0, -0.08),
        duration: _showSearchBar ? _openDuration : _closeDuration,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _showSearchBar ? 1 : 0,
          duration: _showSearchBar
              ? const Duration(milliseconds: 180)
              : _closeDuration,
          curve: Curves.easeOut,
          child: Container(
            color: colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPlannerMode)
                    _buildPlannerMode(colorScheme)
                  else
                    _buildSearchMode(colorScheme),
                  // Toggle button
                  _buildToggleButton(colorScheme),
                  // Suggestions list
                  if (_isPlannerMode)
                    _buildPlannerSuggestions(colorScheme)
                  else
                    _buildSearchSuggestions(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Standard city search mode (original behavior)
  Widget _buildSearchMode(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by city name...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearchChanged('');
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
          const SizedBox(width: 8),
          TextButton(
            onPressed: _handleClose,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Route planner mode with from/to fields
  Widget _buildPlannerMode(ColorScheme colorScheme) {
    return BlocListener<RoutePlannerCubit, RoutePlannerState>(
      listener: (context, plannerState) {
        if (plannerState.status == RoutePlannerStatus.found) {
          // Push planned routes into RoutesBloc
          context.read<RoutesBloc>().add(
                RoutesEvent.setPlannedRoutes(plannerState.plannedRoutes),
              );
          // Select the first planned route
          if (plannerState.plannedRoutes.isNotEmpty) {
            context.read<RoutesBloc>().add(
                  RoutesEvent.selectRoute(plannerState.plannedRoutes.first),
                );
          }
          // Close search overlay
          _handleClose();
        } else if (plannerState.status == RoutePlannerStatus.notFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No cycling route found between '
                '${plannerState.fromCity} and ${plannerState.toCity}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (plannerState.status == RoutePlannerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(plannerState.errorMessage ?? 'An error occurred'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // From field + Cancel
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromController,
                    focusNode: _fromFocusNode,
                    autofocus: true,
                    onChanged: (val) {
                      context.read<RoutePlannerCubit>().setFromCity(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'From city...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      prefixIcon: Icon(
                        Icons.trip_origin_rounded,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _fromController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _fromController.clear();
                                context
                                    .read<RoutePlannerCubit>()
                                    .setFromCity('');
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _handleClose,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // To field + swap button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toController,
                    focusNode: _toFocusNode,
                    onChanged: (val) {
                      context.read<RoutePlannerCubit>().setToCity(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'To city...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _toController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _toController.clear();
                                context
                                    .read<RoutePlannerCubit>()
                                    .setToCity('');
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Swap button
                IconButton(
                  onPressed: _swapCities,
                  icon: Icon(
                    Icons.swap_vert_rounded,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Swap cities',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Find Route button
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<RoutePlannerCubit, RoutePlannerState>(
                builder: (context, plannerState) {
                  final isSearching =
                      plannerState.status == RoutePlannerStatus.searching;
                  final canSearch = _fromController.text.trim().isNotEmpty &&
                      _toController.text.trim().isNotEmpty;
                  return FilledButton.icon(
                    onPressed: canSearch && !isSearching
                        ? _handleFindRoute
                        : null,
                    icon: isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.directions_bike_rounded, size: 18),
                    label: Text(isSearching ? 'Searching...' : 'Find Route'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle between search mode and planner mode
  Widget _buildToggleButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          InkWell(
            onTap: _togglePlannerMode,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlannerMode
                        ? Icons.search_rounded
                        : Icons.alt_route_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPlannerMode ? 'City Search' : 'Route Planner',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Autocomplete suggestions for standard search mode
  Widget _buildSearchSuggestions(ColorScheme colorScheme) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _suggestions.isNotEmpty
              ? Container(
                  key: ValueKey(_suggestions.length),
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
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final city = _suggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_city_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        title: _searchManager.buildHighlightedText(
                          city,
                          widget.controller.text,
                          colorScheme,
                        ),
                        onTap: () => _handleSuggestionTap(city),
                        dense: true,
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Autocomplete suggestions for planner mode
  Widget _buildPlannerSuggestions(ColorScheme colorScheme) {
    final activeQuery = _activePlannerField == _PlannerField.from
        ? _fromController.text
        : _toController.text;

    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _plannerSuggestions.isNotEmpty
              ? Container(
                  key: ValueKey(
                    '${_activePlannerField}_${_plannerSuggestions.length}',
                  ),
                  constraints: const BoxConstraints(maxHeight: 250),
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
                    itemCount: _plannerSuggestions.length,
                    itemBuilder: (context, index) {
                      final city = _plannerSuggestions[index];
                      return ListTile(
                        leading: Icon(
                          _activePlannerField == _PlannerField.from
                              ? Icons.trip_origin_rounded
                              : Icons.location_on_rounded,
                          color: _activePlannerField == _PlannerField.from
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          size: 20,
                        ),
                        title: _searchManager.buildHighlightedText(
                          city,
                          activeQuery,
                          colorScheme,
                        ),
                        onTap: () => _handlePlannerSuggestionTap(city),
                        dense: true,
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

enum _PlannerField { from, to }