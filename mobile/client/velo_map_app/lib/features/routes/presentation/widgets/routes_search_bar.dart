import 'package:flutter/material.dart';
import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';
import 'package:velo_map_app/features/routes/presentation/services/search_manager.dart';

/// Search bar with autocomplete suggestions for city-based route search
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

class _RoutesSearchBarState extends State<RoutesSearchBar> {
  final _searchManager = SearchManager();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSuggestions);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSuggestions);
    super.dispose();
  }

  void _updateSuggestions() {
    setState(() {
      _suggestions = _searchManager.getAutocompleteSuggestions(
        widget.routes,
        widget.controller.text,
      );
    });
  }

  void _handleSuggestionTap(String city) {
    widget.controller.text = city;
    widget.controller.selection = TextSelection.collapsed(offset: city.length);
    widget.onSuggestionSelected(city);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    // Search field
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
                    // Cancel button
                    TextButton(
                      onPressed: widget.onClose,
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
              ),
              // Autocomplete suggestions
              if (_suggestions.isNotEmpty)
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
