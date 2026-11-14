import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../app/widgets.dart';
import '../../../core/utils/time_utils.dart';
import '../../places/data/place.dart';
import '../data/trip.dart';
import '../data/trip_planner.dart';
import 'add_trip_sheet.dart';

class TomorrowScreen extends ConsumerWidget {
  const TomorrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tomorrowTripsStreamProvider);
    final trips = tripsAsync.value ?? const <Trip>[];
    final places = {for (final p in ref.watch(placesProvider)) p.id: p};
    final isMock = ref.watch(directionsProvider).isMock;
    final first = trips.isEmpty ? null : trips.first.leaveAt;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96), // clear the FAB
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOMORROW', style: AppText.eyebrow()),
                      const SizedBox(height: 4),
                      Text(fmtDayHeader(tomorrowDate()), style: AppText.heading(28)),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: AppText.body(color: AppColors.muted),
                          children: [
                            TextSpan(
                              text: trips.isEmpty
                                  ? 'No trips yet'
                                  : '${trips.length} trip${trips.length > 1 ? 's' : ''}',
                            ),
                            if (first != null) ...[
                              const TextSpan(text: ' · first leave '),
                              TextSpan(
                                text: fmtTime(first),
                                style: AppText.body(color: AppColors.amber, w: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconSquare(icon: Icons.settings_outlined, tooltip: 'Settings', onTap: () => context.go('/settings')),
              ],
            ),
            if (isMock) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.science_outlined, size: 18, color: AppColors.ferry),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Example Kolkata routes · no Google key set (MAPS_KEY)',
                        style: AppText.body(size: 12.5, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4),
            if (tripsAsync.isLoading && trips.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tripsAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('Could not read trips: ${tripsAsync.error}', style: AppText.body(color: AppColors.amber)),
              )
            else if (trips.isEmpty)
              const _EmptyState()
            else
              for (var i = 0; i < trips.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FadeSlideIn(
                    delay: i * 80,
                    child: TripCard(trip: trips[i], from: places[trips[i].fromPlaceId], to: places[trips[i].toPlaceId]),
                  ),
                ),
          ],
        ),
      ),
      // Always reachable, however many trip cards push the list past the fold
      // (on a 320 dp phone two cards already do).
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-trip',
        onPressed: () => showAddTripSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add trip'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 60, bottom: 20),
    child: Column(
      children: [
        const Icon(Icons.nightlight_outlined, size: 44, color: AppColors.muted),
        const SizedBox(height: 12),
        Text('Nothing planned for tomorrow', style: AppText.heading(18)),
        const SizedBox(height: 6),
        Text('Add a trip and the plan arrives the night before.', style: AppText.body(color: AppColors.muted)),
      ],
    ),
  );
}

class TripCard extends ConsumerWidget {
  const TripCard({super.key, required this.trip, this.from, this.to});
  final Trip trip;
  final Place? from, to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = cachedRoute(trip);
    final leave = trip.leaveAt;
    return Dismissible(
      key: ValueKey('trip-${trip.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: const Color(0xFF3A1D1D), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF8A80)),
      ),
      onDismissed: (_) => ref.read(planActionsProvider).deleteTrip(trip.id),
      child: AppCard(
        onTap: () => context.push('/route/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Hero(
                  tag: 'leave-${trip.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(leave != null ? fmtTime(leave) : '--:--', style: AppText.leave()),
                  ),
                ),
                const SizedBox(width: 10),
                Text('LEAVE', style: AppText.eyebrow(AppColors.amber.withValues(alpha: 0.8))),
                const Spacer(),
                if (trip.bufferMinutes > 0 && leave != null)
                  Text(
                    'incl. ${trip.bufferMinutes} min buffer',
                    style: AppText.body(size: 11.5, color: AppColors.muted),
                  ),
                if (trip.status == TripStatus.notified) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.muted),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    from?.name ?? '?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 17, w: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(flex: 1, child: _Arrow()),
                const SizedBox(width: 10),
                Flexible(
                  flex: 3,
                  child: Text(
                    to?.name ?? '?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 17, w: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (route != null) ...[
              const SizedBox(height: 14),
              ModeBar(legs: route.legs),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      children: [for (final m in modesOf(route.legs)) ModeDot(mode: m, label: modeLabel(m))],
                    ),
                  ),
                  Text('${route.totalMinutes} min · ₹${route.fare}', style: AppText.body(size: 13, w: FontWeight.w600)),
                ],
              ),
              if (route.walkOnly) ...[
                const SizedBox(height: 8),
                Text('No transit found · take an auto or cab', style: AppText.body(size: 12, color: AppColors.amber)),
              ],
            ] else ...[
              const SizedBox(height: 12),
              Text('Route not fetched yet · tap to retry', style: AppText.body(size: 13, color: AppColors.muted)),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: AppText.body(size: 13, color: AppColors.muted),
                      children: [
                        const TextSpan(text: 'arrive '),
                        TextSpan(
                          text: fmtTime(route?.arriveAt ?? trip.arriveBy),
                          style: AppText.body(size: 13, w: FontWeight.w600),
                        ),
                        TextSpan(text: '  ·  need to be there by ${fmtTime(trip.arriveBy)}'),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 10,
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.line, AppColors.muted])),
          ),
        ),
        const Icon(Icons.play_arrow_rounded, size: 10, color: AppColors.muted),
      ],
    ),
  );
}
