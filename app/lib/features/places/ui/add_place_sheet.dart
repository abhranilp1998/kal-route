import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../data/place.dart';
import 'map_picker_screen.dart';

const _emojis = ['🏠', '🎓', '🏢', '🏋️', '👵', '☕', '🛒', '🏥', '📍'];

Future<void> showPlaceSheet(BuildContext context, {Place? existing}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => PlaceSheet(existing: existing),
);

class PlaceSheet extends ConsumerStatefulWidget {
  const PlaceSheet({super.key, this.existing});
  final Place? existing;
  @override
  ConsumerState<PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends ConsumerState<PlaceSheet> {
  late final name = TextEditingController(text: widget.existing?.name);
  late final address = TextEditingController(text: widget.existing?.address);
  late String emoji = widget.existing?.emoji ?? '📍';
  late double? lat = widget.existing?.lat, lng = widget.existing?.lng;

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await openMapPicker(context, lat: lat, lng: lng);
    if (picked == null) return;
    setState(() {
      lat = picked.lat;
      lng = picked.lng;
      if (picked.address != null) address.text = picked.address!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final hasLoc = lat != null && lng != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? 'Edit place' : 'Add place', style: AppText.heading(22)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in _emojis)
                  GestureDetector(
                    onTap: () => setState(() => emoji = e),
                    child: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: e == emoji ? AppColors.amber.withValues(alpha: 0.14) : AppColors.card2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: e == emoji ? AppColors.amber : Colors.transparent, width: 1.5),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('place-name'),
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name, e.g. Office'),
            ),
            const SizedBox(height: 14),
            Text('LOCATION', style: AppText.eyebrow()),
            const SizedBox(height: 8),
            Material(
              color: AppColors.card2,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                key: const Key('pick-on-map'),
                borderRadius: BorderRadius.circular(14),
                onTap: _pick,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map_outlined, color: AppColors.amber),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasLoc ? 'Pin set' : 'Pick on map', style: AppText.body(size: 15, w: FontWeight.w600)),
                            Text(
                              hasLoc
                                  ? '${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
                                  : 'Search, drop a pin or use your location',
                              style: AppText.body(size: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('place-address'),
              controller: address,
              decoration: const InputDecoration(labelText: 'Address (filled from the map, editable)'),
            ),
            const SizedBox(height: 18),
            FilledButton(key: const Key('save-place'), onPressed: _save, child: Text(editing ? 'Save' : 'Add place')),
            if (editing) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await ref.read(planActionsProvider).deletePlace(widget.existing!.id);
                    nav.pop();
                  },
                  child: const Text('Delete place (and its trips)', style: TextStyle(color: Color(0xFFFF8A80))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (name.text.trim().isEmpty || lat == null || lng == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add a name and pick the location on the map.')));
      return;
    }
    final nav = Navigator.of(context);
    await ref
        .read(planActionsProvider)
        .savePlace(
          Place(
            id: widget.existing?.id ?? 0,
            name: name.text.trim(),
            lat: lat!,
            lng: lng!,
            address: address.text.trim().isEmpty ? null : address.text.trim(),
            emoji: emoji,
          ),
        );
    nav.pop();
  }
}
