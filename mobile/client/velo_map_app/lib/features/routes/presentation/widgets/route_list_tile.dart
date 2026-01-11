import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:velo_map_app/features/routes/domain/models/route_model.dart';

class RouteListTile extends StatelessWidget {
  final RouteModel route;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteListTile({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
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
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share functionality coming soon'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          label: Text(
                            'Share',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // TODO: Implement download functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Download functionality coming soon'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download'),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
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
              '${minElevation.toInt()}m - ${maxElevation.toInt()}m',
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
        controlX, current.dy,
        controlX, next.dy,
        next.dx, next.dy,
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
