import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_stage_entity.dart';

class RouteListTile extends StatelessWidget {
  final RouteEntity route;
  final bool isSelected;
  final VoidCallback onTap;
  final RouteStageEntity? selectedStage;
  final void Function(RouteStageEntity stage)? onStageSelected;
  final VoidCallback? onStageClear;

  const RouteListTile({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
    this.selectedStage,
    this.onStageSelected,
    this.onStageClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    _RouteNumberBadge(
                      routeNumber: route.routeNumber,
                      isSelected: isSelected,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        route.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      _ActionIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share functionality coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 4),
                      _ActionIconButton(
                        icon: Icons.download_rounded,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download functionality coming soon'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                        filled: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  route.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Metadata row
                Row(
                  children: [
                    _MetadataChip(
                      icon: Icons.straighten_rounded,
                      label: route.formattedDistance,
                      isSelected: isSelected,
                    ),
                    const SizedBox(width: 16),
                    _MetadataChip(
                      icon: Icons.trending_up_rounded,
                      label: route.formattedElevation,
                      isSelected: isSelected,
                    ),
                  ],
                ),

                // Expanded content when selected
                if (isSelected) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Elevation Graph
                  _ElevationGraph(
                    elevations: _extractElevations(route.coordinates),
                    colorScheme: colorScheme,
                    isSelected: isSelected,
                  ),

                  // Stages list (if route has stages)
                  if (route.stages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _StagesList(
                      stages: route.stages,
                      selectedStage: selectedStage,
                      onStageSelected: onStageSelected,
                      onStageClear: onStageClear,
                      colorScheme: colorScheme,
                    ),
                  ],

                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<double> _extractElevations(List<List<double>> coordinates) {
    // Extract elevation (3rd value) from each coordinate
    // If no elevation data, return empty list
    return coordinates
        .where((coord) => coord.length >= 3)
        .map((coord) => coord[2])
        .toList();
  }
}

class _ElevationGraph extends StatelessWidget {
  final List<double> elevations;
  final ColorScheme colorScheme;
  final bool isSelected;

  const _ElevationGraph({
    required this.elevations,
    required this.colorScheme,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (elevations.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No elevation data available',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
      );
    }

    final minElevation = elevations.reduce(math.min);
    final maxElevation = elevations.reduce(math.max);
    final elevationRange = maxElevation - minElevation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 16,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Elevation Profile',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${minElevation.toInt()}m, ${maxElevation.toInt()}m',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _ElevationChartPainter(
                elevations: elevations,
                minElevation: minElevation,
                maxElevation: maxElevation,
                elevationRange: elevationRange,
                lineColor: colorScheme.primary,
                fillColor: colorScheme.primary.withValues(alpha: 0.2),
                gridColor: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ElevationChartPainter extends CustomPainter {
  final List<double> elevations;
  final double minElevation;
  final double maxElevation;
  final double elevationRange;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _ElevationChartPainter({
    required this.elevations,
    required this.minElevation,
    required this.maxElevation,
    required this.elevationRange,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (elevations.isEmpty) return;

    final padding = 8.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Calculate points
    final points = <Offset>[];
    final stepX = chartWidth / (elevations.length - 1);

    for (int i = 0; i < elevations.length; i++) {
      final x = padding + (i * stepX);
      final normalizedY = elevationRange > 0
          ? (elevations[i] - minElevation) / elevationRange
          : 0.5;
      final y = padding + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path();
    fillPath.moveTo(padding, padding + chartHeight);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(padding + chartWidth, padding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    // Use smooth curve
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;

      linePath.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ElevationChartPainter oldDelegate) {
    return oldDelegate.elevations != elevations ||
        oldDelegate.lineColor != lineColor;
  }
}

class _RouteNumberBadge extends StatelessWidget {
  final int routeNumber;
  final bool isSelected;

  const _RouteNumberBadge({
    required this.routeNumber,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isSelected
        ? colorScheme.primary
        : colorScheme.primaryContainer;
    final textColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          routeNumber.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: routeNumber > 99 ? 12 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget to display list of stages for a route
class _StagesList extends StatelessWidget {
  final List<RouteStageEntity> stages;
  final RouteStageEntity? selectedStage;
  final void Function(RouteStageEntity stage)? onStageSelected;
  final VoidCallback? onStageClear;
  final ColorScheme colorScheme;

  const _StagesList({
    required this.stages,
    required this.selectedStage,
    required this.onStageSelected,
    required this.onStageClear,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.alt_route_rounded,
              size: 16,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              'Stages',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const Spacer(),
            if (selectedStage != null)
              GestureDetector(
                onTap: onStageClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Show full route',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...stages.map(
          (stage) => _StageItem(
            stage: stage,
            isSelected: selectedStage?.stage == stage.stage,
            onTap: () {
              if (selectedStage?.stage == stage.stage) {
                onStageClear?.call();
              } else {
                onStageSelected?.call(stage);
              }
            },
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

/// Widget for individual stage item
class _StageItem extends StatelessWidget {
  final RouteStageEntity stage;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _StageItem({
    required this.stage,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Stage number badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stage.stage}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Stage info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.straighten_rounded,
                        size: 12,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        stage.formattedDistance,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.trending_up_rounded,
                        size: 12,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        stage.formattedElevation,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon button for share/download actions in the card header
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final bool filled;

  const _ActionIconButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
