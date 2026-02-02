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

class _RoutesSearchBarState extends State<RoutesSearchBar>
    with TickerProviderStateMixin {
  final _searchManager = SearchManager();
  List<String> _suggestions = [];
  bool _showSearchBar = false;
  bool _closing = false;
  static const _closeDuration = Duration(milliseconds: 200);
  static const _openDuration = Duration(milliseconds: 240);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSuggestions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showSearchBar = true);
      }
    });
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
                  ),
                  // Autocomplete suggestions
                  ClipRect(
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
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                      color: colorScheme.shadow.withValues(
                                        alpha: 0.1,
                                      ),
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
                                      title: _searchManager
                                          .buildHighlightedText(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
