import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../app/widgets.dart';
import '../data/place.dart';
import 'add_place_sheet.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('SAVED', style: AppText.eyebrow()),
            const SizedBox(height: 4),
            Text('Places', style: AppText.heading(28)),
            const SizedBox(height: 4),
            Text('${places.length} place${places.length == 1 ? '' : 's'} · long-press to edit',
                style: AppText.body(color: AppColors.muted)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                for (var i = 0; i < places.length; i++)
                  FadeSlideIn(delay: i * 50, child: _PlaceTile(place: places[i])),
                _AddTile(onTap: () => showPlaceSheet(context)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Tap a place to edit · pins come from the map',
                  style: AppText.body(size: 13, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place});
  final Place place;
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => showPlaceSheet(context, existing: place),
          onTap: () => showPlaceSheet(context, existing: place),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(16)),
                child: Text(place.emoji, style: const TextStyle(fontSize: 30)),
              ),
              const Spacer(),
              Text(place.name, style: AppText.body(size: 17, w: FontWeight.w700), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(place.address ?? '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                  style: AppText.body(size: 12, color: AppColors.muted), overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      );
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorder(),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: AppColors.amber),
              ),
              const SizedBox(height: 8),
              Text('Add place', style: AppText.body(color: AppColors.muted, w: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)).deflate(0.75);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = const Color(0xFF3A3E44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
