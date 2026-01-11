import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:velo_map_app/features/routes/widgets/sheet_drag_handle.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final DraggableScrollableController _sheet = DraggableScrollableController();

  static const double _min = 0.15;
  static const double _mid = 0.25;
  static const double _max = 0.50;

  final snapSizes = <double>[_min, _mid, _max];

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MapboxMap? mapboxMap;

    onMapCreated(MapboxMap mapboxMap) {
      mapboxMap = mapboxMap;
    }

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(key: ValueKey("mapWidget"), onMapCreated: onMapCreated),
          DraggableScrollableSheet(
            controller: _sheet,
            initialChildSize: 0.15,
            minChildSize: _min,
            maxChildSize: _max,
            snap: true,
            snapSizes: const [_min, _max],
            snapAnimationDuration: const Duration(milliseconds: 220),
            builder: (context, scrollController) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: Offset(0, -4),
                          color: Color(0x22000000),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SheetDragHandle(
                          sheet: _sheet,
                          min: _min,
                          max: _max,
                          snapSizes: snapSizes,
                        ),
                        // const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 40,
                            itemBuilder: (context, i) {
                              // final item = items[i];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.blue.withOpacity(
                                      0.15,
                                    ), // 💦 цвет волны
                                    highlightColor: Colors.blue.withOpacity(
                                      0.05,
                                    ), // 👆 цвет удержания
                                    onTap: () => _sheet.animateTo(
                                      _max,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOutCubic,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.blueAccent,
                                            child: Text(
                                              '16',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Title',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Subtitle',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
