import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,

                          onVerticalDragUpdate: (details) {
                            if (!_sheet.isAttached) return;

                            final screenH = MediaQuery.of(context).size.height;
                            final delta = -details.delta.dy / screenH;

                            final next = (_sheet.size + delta)
                                .clamp(_min, _max)
                                .toDouble();
                            _sheet.jumpTo(next);
                          },

                          onVerticalDragEnd: (_) {
                            if (!_sheet.isAttached) return;

                            final current = _sheet.size;

                            // ближайший "магнит"
                            double nearest = snapSizes.first;
                            double bestDist = (current - nearest).abs();

                            for (final s in snapSizes.skip(1)) {
                              final d = (current - s).abs();
                              if (d < bestDist) {
                                bestDist = d;
                                nearest = s;
                              }
                            }

                            _sheet.animateTo(
                              nearest,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            );
                          },

                          child: SizedBox(
                            height: 30,
                            width: double.infinity,
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 40,
                            itemBuilder: (context, i) => ListTile(
                              title: Text('Item $i'),
                              subtitle: const Text(
                                'Scroll list; drag sheet by handle',
                              ),
                              onTap: () {
                                _sheet.animateTo(
                                  _max,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
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
