import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:velo_map_app/features/routes/data/repositories/routes_repository.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_bloc.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_event.dart';
import 'package:velo_map_app/features/routes/presentation/bloc/routes_state.dart';
import 'package:velo_map_app/features/routes/presentation/widgets/sheet_drag_handle.dart';

class Routes extends StatefulWidget {
  final RoutesRepository routesRepository;
  const Routes({super.key, required this.routesRepository});

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

    void onMapCreated(MapboxMap mapboxMap) {
      mapboxMap = mapboxMap;
    }

    return BlocProvider(
      create: (context) =>
          RoutesBloc(repository: widget.routesRepository)
            ..add(RoutesEvent.requested()),
      child: Scaffold(
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
                            child: BlocBuilder<RoutesBloc, RoutesState>(
                              builder: (context, state) {
                                return state.when(
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  loaded: (routes) {
                                    if (routes.isEmpty) {
                                      return const Center(
                                        child: Text("No routes found"),
                                      );
                                    }
                                    return ListView.builder(
                                      controller: scrollController,
                                      itemCount: routes.length,
                                      itemBuilder: (context, i) {
                                        final route = routes[i];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              splashColor: Colors.blue
                                                  .withAlpha(
                                                    38,
                                                  ), // 💦 цвет волны
                                              highlightColor: Colors.blue
                                                  .withAlpha(
                                                    13,
                                                  ), // 👆 цвет удержания
                                              onTap: () => _sheet.animateTo(
                                                _max,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOutCubic,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor:
                                                          Colors.blueAccent,
                                                      child: Text(
                                                        route.id,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            route.name,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            'Subtitle',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.chevron_right,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  error: (message) => Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(message),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () =>
                                              context.read<RoutesBloc>().add(
                                                const RoutesEvent.requested(),
                                              ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
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
      ),
    );
  }
}
