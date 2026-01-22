import 'package:flutter/material.dart';

/// Development status of a route stage
enum RouteStageStatus {
  certified,
  developedWithSigns,
  developed,
  underDevelopment,
  planning,
  unknown;

  /// Parse status from description text
  static RouteStageStatus fromDescription(String description) {
    final upperDesc = description.toUpperCase();

    if (upperDesc.contains('CERTIFIED')) {
      return RouteStageStatus.certified;
    } else if (upperDesc.contains('DEVELOPED_WITH_SIGNS') ||
        upperDesc.contains('DEVELOPED WITH SIGNS')) {
      return RouteStageStatus.developedWithSigns;
    } else if (upperDesc.contains('UNDER_DEVELOPMENT') ||
        upperDesc.contains('UNDER DEVELOPMENT')) {
      return RouteStageStatus.underDevelopment;
    } else if (upperDesc.contains('DEVELOPED')) {
      return RouteStageStatus.developed;
    } else if (upperDesc.contains('PLANNING')) {
      return RouteStageStatus.planning;
    }

    return RouteStageStatus.unknown;
  }

  /// Get the icon for this status
  IconData get icon {
    switch (this) {
      case RouteStageStatus.certified:
        return Icons.verified_rounded;
      case RouteStageStatus.developedWithSigns:
        return Icons.signpost_rounded;
      case RouteStageStatus.developed:
        return Icons.check_circle_rounded;
      case RouteStageStatus.underDevelopment:
        return Icons.construction_rounded;
      case RouteStageStatus.planning:
        return Icons.pending_rounded;
      case RouteStageStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  /// Get the color for this status
  Color get color {
    switch (this) {
      case RouteStageStatus.certified:
        return const Color(0xFF4CAF50); // Green
      case RouteStageStatus.developedWithSigns:
        return const Color(0xFF2196F3); // Blue
      case RouteStageStatus.developed:
        return const Color(0xFF009688); // Teal
      case RouteStageStatus.underDevelopment:
        return const Color(0xFFFF9800); // Orange
      case RouteStageStatus.planning:
        return const Color(0xFF9E9E9E); // Grey
      case RouteStageStatus.unknown:
        return const Color(0xFF757575); // Dark Grey
    }
  }

  /// Get a human-readable label for this status
  String get label {
    switch (this) {
      case RouteStageStatus.certified:
        return 'Certified';
      case RouteStageStatus.developedWithSigns:
        return 'Developed with Signs';
      case RouteStageStatus.developed:
        return 'Developed';
      case RouteStageStatus.underDevelopment:
        return 'Under Development';
      case RouteStageStatus.planning:
        return 'Planning';
      case RouteStageStatus.unknown:
        return 'Unknown';
    }
  }
}
