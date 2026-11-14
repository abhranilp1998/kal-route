import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/db/seed.dart';
import '../../../core/notifications/nightly_job.dart';
import '../../../core/notifications/notification_service.dart';
import '../data/prefs.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(prefsProvider);
    final notifier = ref.read(prefsProvider.notifier);
    final isMock = ref.watch(directionsProvider).isMock;

    Future<void> save(Prefs prefs) async {
      await notifier.update(prefs);
      await scheduleNextRun(prefs.notifyHour, prefs.notifyMinute);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('PREFERENCES', style: AppText.eyebrow()),
            const SizedBox(height: 4),
            Text('Settings', style: AppText.heading(28)),
            _sec('NIGHTLY PLAN'),
            _group([
              _row(
                'Notify me at',
                backgroundJobsSupported ? "Tomorrow's plan arrives as one card" : 'Android only · web has no background jobs',
                trailing: Text('${p.notifyHour.toString().padLeft(2, '0')}:${p.notifyMinute.toString().padLeft(2, '0')}',
                    style: AppText.body(size: 15, w: FontWeight.w700, color: AppColors.amber)),
                onTap: () async {
                  final t = await showTimePicker(
                      context: context, initialTime: TimeOfDay(hour: p.notifyHour, minute: p.notifyMinute));
                  if (t != null) await save(p.copyWith(notifyHour: t.hour, notifyMinute: t.minute));
                },
              ),
              _row('Buffer', 'Tea break and slack before leaving',
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _stepBtn('−', p.bufferMinutes > 0 ? () => save(p.copyWith(bufferMinutes: p.bufferMinutes - 1)) : null),
                    SizedBox(
                      width: 56,
                      child: Text('${p.bufferMinutes} min',
                          textAlign: TextAlign.center,
                          style: AppText.body(size: 15, w: FontWeight.w700, color: AppColors.amber)),
                    ),
                    _stepBtn('+', p.bufferMinutes < 30 ? () => save(p.copyWith(bufferMinutes: p.bufferMinutes + 1)) : null),
                  ])),
            ]),
            _sec('ROUTES'),
            _group([
              _row('Priority', 'How the best route is picked'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(children: [
                  for (final (key, label) in const [
                    ('fastest', 'Fastest'),
                    ('cheapest', 'Cheapest'),
                    ('least_changes', 'Few changes')
                  ]) ...[
                    if (key != 'fastest') const SizedBox(width: 6),
                    Expanded(child: _radio(label, p.priority == key, () => save(p.copyWith(priority: key)))),
                  ],
                ]),
              ),
              _row('Avoid long walks', 'Skip routes with over 15 min walking',
                  trailing: Switch(
                    value: p.avoidLongWalks,
                    activeThumbColor: AppColors.onAmber,
                    activeTrackColor: AppColors.amber,
                    onChanged: (v) => save(p.copyWith(avoidLongWalks: v)),
                  ),
                  border: true),
            ]),
            _sec('TOOLS'),
            _group([
              _row('Run nightly job now',
                  backgroundJobsSupported ? 'Fetch routes and send the card' : 'Fetch routes now (web: no background run)',
                  trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.amber),
                  onTap: () => _runNow(context, ref)),
              if (backgroundJobsSupported)
                _row('Battery optimisation', "Turn off so the nightly job isn't killed",
                    trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                    onTap: () => _batteryInfo(context)),
              _row('Route data', isMock ? 'Example Kolkata routes (no MAPS_KEY set)' : 'Google Directions API (transit)',
                  trailing: Icon(isMock ? Icons.science_outlined : Icons.cloud_done_outlined,
                      color: isMock ? AppColors.ferry : AppColors.bus)),
              _row('Reset example data', 'Re-seed Kolkata places and trips',
                  trailing: const Icon(Icons.restart_alt, color: AppColors.muted), onTap: () async {
                await resetExampleData(ref.read(databaseProvider), ref.read(directionsProvider), p);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Example data restored')));
                }
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _runNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final s = await runNightlyPlan(ref.read(databaseProvider), ref.read(directionsProvider), ref.read(prefsProvider));
    if (backgroundJobsSupported) {
      if (s.tripCount > 0) await NotificationService.show(title: s.title, body: s.body, payload: 'tomorrow');
      messenger.showSnackBar(SnackBar(content: Text('Notification sent · ${s.title}')));
    } else {
      // Web has no system notifications from background work; show the same
      // card content in-app and say so.
      messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Text('${s.title} · ${s.body}\nRoutes saved. (Web: no system notification or 9 PM background run.)')));
    }
  }

  void _batteryInfo(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Keep the 9 PM job alive'),
          content: const Text(
              'Xiaomi, Oppo, Vivo and Realme phones often kill background apps. Open Settings → Apps → '
              'Commute Planner → Battery and choose "No restrictions" so the nightly plan arrives on time.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
        ),
      );

  Widget _sec(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
        child: Text(s, style: AppText.eyebrow()),
      );

  Widget _group(List<Widget> children) => Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );

  Widget _row(String title, String sub, {Widget? trailing, VoidCallback? onTap, bool border = false}) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: border ? const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))) : null,
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.body(size: 15, w: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(sub, style: AppText.body(size: 12, color: AppColors.muted)),
              ]),
            ),
            ?trailing,
          ]),
        ),
      );

  Widget _stepBtn(String s, VoidCallback? onTap) => Material(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
              width: 32, height: 32, child: Center(child: Text(s, style: AppText.body(size: 18)))),
        ),
      );

  Widget _radio(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: on ? AppColors.amber.withValues(alpha: 0.14) : AppColors.card2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: on ? AppColors.amber : Colors.transparent, width: 1.5),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(size: 12, w: FontWeight.w600, color: on ? AppColors.amber : AppColors.muted)),
        ),
      );
}
