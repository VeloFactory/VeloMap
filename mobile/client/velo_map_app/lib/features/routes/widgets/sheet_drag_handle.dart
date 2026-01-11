import 'package:flutter/material.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({
    super.key,
    required this.sheet,
    required this.min,
    required this.max,
    required this.snapSizes,
    this.height = 30,
    this.handleWidth = 46,
    this.handleHeight = 4,
    this.animateDuration = const Duration(milliseconds: 220),
    this.animateCurve = Curves.easeOut,
  });

  final DraggableScrollableController sheet;
  final double min;
  final double max;
  final List<double> snapSizes;

  final double height;
  final double handleWidth;
  final double handleHeight;

  final Duration animateDuration;
  final Curve animateCurve;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (!sheet.isAttached) return;

        final screenH = MediaQuery.of(context).size.height;
        final delta = -details.delta.dy / screenH;
        final next = (sheet.size + delta).clamp(min, max).toDouble();

        sheet.jumpTo(next);
      },
      onVerticalDragEnd: (_) {
        if (!sheet.isAttached || snapSizes.isEmpty) return;

        final current = sheet.size;

        double nearest = snapSizes.first;
        double bestDist = (current - nearest).abs();

        for (final s in snapSizes.skip(1)) {
          final d = (current - s).abs();
          if (d < bestDist) {
            bestDist = d;
            nearest = s;
          }
        }

        sheet.animateTo(
          nearest.clamp(min, max).toDouble(),
          duration: animateDuration,
          curve: animateCurve,
        );
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Center(
          child: Container(
            width: handleWidth,
            height: handleHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(handleHeight / 2),
            ),
          ),
        ),
      ),
    );
  }
}
