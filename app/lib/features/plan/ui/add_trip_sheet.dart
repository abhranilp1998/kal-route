import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../app/widgets.dart';
import '../../../core/utils/time_utils.dart';
import '../../places/data/place.dart';
import '../../route/data/route_result.dart';
import '../data/trip.dart';
import '../data/trip_planner.dart';

Future<void> showAddTripSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const AddTripSheet(),
);

class AddTripSheet extends ConsumerStatefulWidget {
  const AddTripSheet({super.key});
  @override
  ConsumerState<AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends ConsumerState<AddTripSheet> {
  int? fromId, toId;
  TimeOfDay arriveBy = const TimeOfDay(hour: 10, minute: 0);
  RouteResult? preview;
  bool loading = false;
  String? error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    final places = ref.read(placesProvider);
    if (places.length >= 2) {
      fromId = places[0].id;
      toId = places[1].id;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPreview());
    }
  }

  Trip _draft() {
    final day = tomorrowDate();
    return Trip(
      date: day,
      fromPlaceId: fromId!,
      toPlaceId: toId!,
      arriveBy: atTime(day, arriveBy.hour, arriveBy.minute),
    );
  }

  Future<void> _refreshPreview() async {
    if (fromId == null || toId == null || fromId == toId) {
      setState(() => preview = null);
      return;
    }
    final req = ++_req;
    setState(() {
      loading = true;
      error = null;
    });
    final repo = ref.read(placeRepoProvider);
    try {
      final from = await repo.byId(fromId!), to = await repo.byId(toId!);
      if (from == null || to == null) throw StateError('place missing');
      final r = await planTrip(
        _draft(),
        from: from,
        to: to,
        client: ref.read(directionsProvider),
        prefs: ref.read(prefsProvider),
      );
      if (!mounted || req != _req) return;
      setState(() {
        preview = r;
        loading = false;
        error = r == null ? 'No transit route found' : null;
      });
    } catch (e) {
      if (!mounted || req != _req) return;
      setState(() {
        loading = false;
        error = 'Could not fetch route';
      });
    }
  }

  void _shift(int minutes) {
    final total = (arriveBy.hour * 60 + arriveBy.minute + minutes) % (24 * 60);
    setState(() => arriveBy = TimeOfDay(hour: total ~/ 60, minute: total % 60));
    _refreshPreview();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final prefs = ref.watch(prefsProvider);
    final leave = preview?.leaveAt.subtract(Duration(minutes: prefs.bufferMinutes));
    final valid = fromId != null && toId != null && fromId != toId;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Plan a trip', style: AppText.heading(22)),
            _label('FROM'),
            _chips(places, fromId, (id) {
              setState(() => fromId = id);
              _refreshPreview();
            }),
            _label('TO'),
            _chips(places, toId, (id) {
              setState(() => toId = id);
              _refreshPreview();
            }),
            _label('ARRIVE BY · ${fmtShortDay(tomorrowDate()).toUpperCase()}'),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: arriveBy);
                      if (t != null) {
                        setState(() => arriveBy = t);
                        _refreshPreview();
                      }
                    },
                    child: Text(
                      '${arriveBy.hour}:${arriveBy.minute.toString().padLeft(2, '0')}',
                      style: AppText.body(size: 30, w: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  _stepBtn('−15', () => _shift(-15)),
                  const SizedBox(width: 6),
                  _stepBtn('+15', () => _shift(15)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: _previewCard(leave)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: valid
                  ? () async {
                      final nav = Navigator.of(context);
                      await ref.read(planActionsProvider).addTrip(_draft());
                      nav.pop();
                    }
                  : null,
              child: const Text('Plan it'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCard(DateTime? leave) {
    if (fromId != null && fromId == toId) {
      return _box(Text('Pick two different places', style: AppText.body(color: AppColors.muted)));
    }
    if (loading && preview == null) {
      return _box(
        const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (error != null) return _box(Text(error!, style: AppText.body(color: AppColors.amber)));
    final r = preview;
    if (r == null) return const SizedBox.shrink();
    final transit = r.legs.where((l) => !l.isWalk).toList();
    return _box(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(fmtTime(leave!), style: AppText.leave(26)),
              const SizedBox(width: 8),
              Text('LEAVE', style: AppText.eyebrow(AppColors.amber.withValues(alpha: 0.8))),
              const SizedBox(width: 8),
              Text('arrive ${fmtTime(r.arriveAt)}', style: AppText.body(size: 12, color: AppColors.muted)),
              const Spacer(),
              Text('${r.totalMinutes} min · ₹${r.fare}', style: AppText.body(size: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          ModeBar(legs: r.legs),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              for (final l in transit) ModeDot(mode: l.mode, label: '${l.line ?? modeLabel(l.mode)} → ${l.to}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ref.read(directionsProvider).isMock
                ? 'Leave time includes your ${ref.read(prefsProvider).bufferMinutes} min buffer · example route data'
                : 'Leave time includes your ${ref.read(prefsProvider).bufferMinutes} min buffer · Google transit',
            style: AppText.body(size: 11.5, color: AppColors.faint),
          ),
        ],
      ),
    );
  }

  Widget _box(Widget child) => Container(
    key: ValueKey(child.hashCode),
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(16)),
    child: child,
  );

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(s, style: AppText.eyebrow()),
  );

  Widget _stepBtn(String label, VoidCallback onTap) => Material(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: AppText.body(size: 13, w: FontWeight.w600, color: AppColors.muted),
        ),
      ),
    ),
  );

  Widget _chips(List<Place> places, int? selected, ValueChanged<int> onPick) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [for (final p in places) _PlaceChip(place: p, selected: p.id == selected, onTap: () => onPick(p.id))],
  );
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({required this.place, required this.selected, required this.onTap});
  final Place place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.amber.withValues(alpha: 0.12) : AppColors.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.amber : Colors.transparent, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(place.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            place.name,
            style: AppText.body(size: 14, w: FontWeight.w600, color: selected ? AppColors.amber : AppColors.text),
          ),
        ],
      ),
    ),
  );
}
