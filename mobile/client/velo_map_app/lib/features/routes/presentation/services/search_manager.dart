import 'package:flutter/material.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';

/// Manages search functionality including autocomplete suggestions and text highlighting
class SearchManager {
  /// Get autocomplete city suggestions based on search query
  List<String> getAutocompleteSuggestions(
    List<RouteEntity> routes,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];

    // Collect all unique cities from all routes
    final allCities = <String>{};
    for (final route in routes) {
      allCities.addAll(route.cities);
    }

    // Filter and limit suggestions
    return allCities
        .where((city) => city.toLowerCase().contains(normalizedQuery))
        .take(8)
        .toList()
      ..sort((a, b) {
        // Prioritize cities that start with the query
        final aStarts = a.toLowerCase().startsWith(normalizedQuery);
        final bStarts = b.toLowerCase().startsWith(normalizedQuery);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.compareTo(b);
      });
  }

  /// Build text with the search query highlighted
  Widget buildHighlightedText(
    String text,
    String query,
    ColorScheme colorScheme,
  ) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();
    final matchStart = lowerText.indexOf(lowerQuery);

    if (matchStart < 0) return Text(text);

    final matchEnd = matchStart + normalizedQuery.length;
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
}
