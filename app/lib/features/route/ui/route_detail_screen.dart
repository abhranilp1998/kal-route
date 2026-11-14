import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../app/widgets.dart';
import '../../../core/utils/time_utils.dart';
import '../../plan/data/trip_planner.dart';
import '../data/timeline.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  const RouteDetailScreen({super.key, required this.tripId});
  final int tripId;
  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
    ..forward();
  bool refreshing = false;

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => refreshing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(planActionsProvider).replan(widget.tripId);
      _draw.forward(from: 0);
      messenger.showSnackBar(const SnackBar(content: Text('Route updated')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not refresh: $e')));
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripProvider(widget.tripId));
    final places = {for (final p in ref.watch(placesProvider)) p.id: p};
    final trip = tripAsync.value;
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.bg),
        body: Center(child: tripAsync.isLoading ? const CircularProgressIndicator() : const Text('Trip not found')),
      );
    }
    final from = places[trip.fromPlaceId], to = places[trip.toPlaceId];
    final route = cachedRoute(trip);
    final example = trip.routeSource == 'example';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  IconSquare(
                    icon: Icons.chevron_left,
                    tooltip: 'Back',
                    onTap: () => context.canPop() ? context.pop() : context.go('/tomorrow'),
                  ),
                  Expanded(
                    child: Text(
                      '${from?.name ?? '?'} → ${to?.name ?? '?'}',
                      textAlign: TextAlign.center,
                      style: AppText.heading(20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  refreshing
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconSquare(icon: Icons.refresh, tooltip: 'Fetch route again', onTap: _refresh),
                ],
              ),
            ),
            Expanded(
              child: route == null
                  ? Center(
                      child: Text('No route saved yet. Tap ↻ to fetch.', style: AppText.body(color: AppColors.muted)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        Row(
                          children: [
                            _pill(
                              'LEAVE',
                              trip.leaveAt != null ? fmtTime(trip.leaveAt!) : '--',
                              amber: true,
                              heroTag: 'leave-${trip.id}',
                            ),
                            const SizedBox(width: 8),
                            _pill('ARRIVE', fmtTime(route.arriveAt)),
                            const SizedBox(width: 8),
                            _pill('FARE', route.fare > 0 ? '₹${route.fare}' : '—'),
                          ],
                        ),
                        if (route.walkOnly) ...[
                          const SizedBox(height: 12),
                          AppCard(
                            child: Row(
                              children: [
                                const Icon(Icons.local_taxi_outlined, color: AppColors.amber),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'No bus or metro found for this trip. Take an auto or cab instead.',
                                    style: AppText.body(size: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        AnimatedBuilder(
                          animation: _draw,
                          builder: (context, _) => TimelineView(
                            timeline: buildTimeline(
                              route: route,
                              leaveAt: trip.leaveAt,
                              bufferMinutes: trip.bufferMinutes,
                              startName: from?.name ?? 'Start',
                              startSubtitle: from?.address,
                              endName: to?.name ?? 'Destination',
                              arriveBy: trip.arriveBy,
                            ),
                            progress: Curves.easeOutCubic.transform(_draw.value),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            [
                              example ? 'EXAMPLE ROUTE DATA' : 'GOOGLE TRANSIT',
                              if (trip.routeFetchedAt != null) 'UPDATED ${fmtTime(trip.routeFetchedAt!)}',
                            ].join(' · '),
                            style: AppText.eyebrow(AppColors.faint).copyWith(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live trip guidance ("leave now", "get off next stop") is planned for v2.'),
                  ),
                ),
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: const Text('Start trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String k, String v, {bool amber = false, String? heroTag}) {
    Widget value = Text(
      v,
      style: AppText.body(size: 20, w: FontWeight.w700, color: amber ? AppColors.amber : AppColors.text),
    );
    if (heroTag != null) {
      value = Hero(
        tag: heroTag,
        child: Material(type: MaterialType.transparency, child: value),
      );
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: AppText.eyebrow().copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            value,
          ],
        ),
      ),
    );
  }
}

/// Vertical timeline: nodes interleaved with segments, drawn top to bottom.
class TimelineView extends StatelessWidget {
  const TimelineView({super.key, required this.timeline, required this.progress});
  final Timeline timeline;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final n = timeline.nodes.length;
    final rows = <Widget>[];
    for (var i = 0; i < n; i++) {
      final visible = ((progress * n) - i).clamp(0.0, 1.0);
      rows.add(Opacity(opacity: visible, child: _nodeRow(timeline.nodes[i])));
      if (i < timeline.segments.length) {
        rows.add(_segRow(timeline.segments[i], ((progress * n) - i - 0.3).clamp(0.0, 1.0)));
      }
    }
    return Column(children: rows);
  }

  Color _nodeColor(TimelineNode node) => switch (node.kind) {
    NodeKind.leave => AppColors.amber,
    NodeKind.arrive => AppColors.text,
    _ => node.mode != null ? AppColors.forMode(node.mode!) : AppColors.muted,
  };

  Widget _nodeRow(TimelineNode node) {
    final c = _nodeColor(node);
    final filled = node.kind == NodeKind.arrive;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            fmtTime(node.time),
            style: AppText.body(
              size: 14,
              w: FontWeight.w600,
              color: switch (node.kind) {
                NodeKind.leave => AppColors.amber,
                NodeKind.arrive => AppColors.text,
                _ => AppColors.muted,
              },
            ),
          ),
        ),
        SizedBox(
          width: 26,
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: filled ? c : AppColors.bg,
                shape: BoxShape.circle,
                border: Border.all(color: c, width: 3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.title,
                style: AppText.body(
                  size: 16,
                  w: FontWeight.w600,
                  color: node.kind == NodeKind.leave ? AppColors.amber : AppColors.text,
                ),
              ),
              if (node.subtitle != null) Text(node.subtitle!, style: AppText.body(size: 12, color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _segRow(TimelineSegment s, double p) {
    final l = s.leg;
    final mode = l?.mode ?? 'BUFFER';
    final c = l == null ? AppColors.amber : AppColors.forMode(mode);
    final badgeText = switch (mode) {
      'BUFFER' => '☕ Buffer',
      'WALK' => '🚶 Walk',
      'METRO' => 'Ⓜ ${l!.line ?? 'Metro'}',
      'BUS' => '🚌 Bus ${l!.line ?? ''}',
      'AUTO' => '🛺 ${l!.line ?? 'Auto'}',
      'FERRY' => '⛴ ${l!.line ?? 'Ferry'}',
      'TRAIN' => '🚆 ${l!.line ?? 'Train'}',
      _ => l!.line ?? mode,
    };
    final detail = l == null
        ? '${s.minutes} min slack · tea, lift, traffic'
        : l.isWalk
        ? '${l.minutes} min'
        : '→ ${l.to}${l.stops != null ? ' · ${l.stops} stops' : ''} · ${l.minutes} min'
              '${l.fareInr != null && l.fareInr! > 0 ? ' · ₹${l.fareInr}' : ''}';
    final dashed = l == null || l.isWalk;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 52),
          SizedBox(
            width: 26,
            child: CustomPaint(
              painter: _SegPainter(dashed ? (l == null ? c : AppColors.walk) : c, dashed: dashed, progress: p),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Opacity(
              opacity: p,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: AppText.body(
                          size: 12,
                          w: FontWeight.w700,
                          color: l != null && l.isWalk ? const Color(0xFFB9BDC4) : Color.lerp(c, Colors.white, 0.25)!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(detail, style: AppText.body(size: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegPainter extends CustomPainter {
  _SegPainter(this.color, {required this.dashed, required this.progress});
  final Color color;
  final bool dashed;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final h = (size.height + 8) * progress;
    final paint = Paint()
      ..color = color
      ..strokeWidth = dashed ? 3 : 4
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      for (double y = -2; y < h - 4; y += 10) {
        canvas.drawLine(Offset(x, y), Offset(x, (y + 5).clamp(0, h - 4)), paint);
      }
    } else {
      canvas.drawLine(Offset(x, -4), Offset(x, -4 + h), paint);
    }
  }

  @override
  bool shouldRepaint(_SegPainter old) => old.progress != progress || old.color != color;
}
