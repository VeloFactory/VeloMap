import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/route_list_tile.dart';

/// Bottom sheet containing routes list and selection interface
class RoutesBottomSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final ScrollController scrollController;
  final RoutesState state;
  final VoidCallback onSearchPressed;
  final double minSize;
  final double midSize;
  final double maxSize;
  final List<double> snapSizes;

  const RoutesBottomSheet({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.state,
    required this.onSearchPressed,
    required this.minSize,
    required this.midSize,
    required this.maxSize,
    required this.snapSizes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          _buildSheetHeader(context, colorScheme),
          // Content
          Expanded(
            child: state.error != null
                ? _buildErrorView(state.error!, colorScheme)
                : state.routes.isEmpty && !state.isLoading
                ? _buildEmptyView(colorScheme)
                : _buildRoutesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!controller.isAttached) return;
        // Toggle: minimize if opened, expand to middle if minimized
        if (controller.size <= minSize + 0.01) {
          // Sheet is minimized -> expand to middle
          controller.animateTo(
            midSize,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          // Sheet is opened -> minimize
          controller.animateTo(
            minSize,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onVerticalDragUpdate: (details) {
        if (!controller.isAttached) return;
        final screenH = MediaQuery.of(context).size.height;
        final delta = -details.delta.dy / screenH;
        final next = (controller.size + delta)
            .clamp(minSize, maxSize)
            .toDouble();
        controller.jumpTo(next);
      },
      onVerticalDragEnd: (_) {
        if (!controller.isAttached) return;
        final current = controller.size;
        double nearest = snapSizes.first;
        double bestDist = (current - nearest).abs();
        for (final s in snapSizes.skip(1)) {
          final d = (current - s).abs();
          if (d < bestDist) {
            bestDist = d;
            nearest = s;
          }
        }
        controller.animateTo(
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
          const SizedBox(height: 8),

          // Title row
          _buildTitleRow(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, ColorScheme colorScheme) {
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
                'All Routes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Search icon button
              IconButton(
                onPressed: onSearchPressed,
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
                  context.read<RoutesBloc>().add(
                    const RoutesEvent.clearSearch(),
                  );
                },
                onPressed: onSearchPressed,
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

  Widget _buildRoutesList(BuildContext context) {
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
