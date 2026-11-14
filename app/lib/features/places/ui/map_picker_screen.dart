import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/geo/geocoding_service.dart';

/// Result of the map picker.
class PickedLocation {
  const PickedLocation(this.lat, this.lng, {this.address, this.fullAddress});
  final double lat, lng;
  final String? address, fullAddress;
}

/// Kolkata (Esplanade) – the default view when there's no better start point.
const kolkataCenter = LatLng(22.5646, 88.3510);

Future<PickedLocation?> openMapPicker(BuildContext context, {double? lat, double? lng}) =>
    Navigator.of(context, rootNavigator: true).push<PickedLocation>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MapPickerScreen(initial: lat != null && lng != null ? LatLng(lat, lng) : null),
      ),
    );

/// Full-screen place picker on OpenStreetMap:
/// * pan the map or tap anywhere to drop the pin (pin stays in the centre),
/// * search an address (Nominatim, on submit only),
/// * jump to the current GPS / browser location,
/// * the pin is reverse-geocoded to fill the address.
class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key, this.initial});
  final LatLng? initial;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final _map = MapController();
  final _search = TextEditingController();
  late LatLng _center = widget.initial ?? kolkataCenter;
  GeoResult? _address;
  bool _resolving = false;
  String? _addressError;
  List<GeoResult>? _results;
  bool _searching = false;
  bool _locating = false;
  Timer? _debounce;
  int _reverseReq = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reverseGeocode());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onMoved(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    _debounce?.cancel();
    setState(() {
      _resolving = true;
      _addressError = null;
    });
    // Reverse-geocode once the map has been still for a moment (and the
    // geocoder itself enforces Nominatim's 1 request/second limit).
    _debounce = Timer(const Duration(milliseconds: 900), _reverseGeocode);
  }

  Future<void> _reverseGeocode() async {
    final req = ++_reverseReq;
    setState(() => _resolving = true);
    try {
      final r = await ref.read(geocoderProvider).reverse(_center.latitude, _center.longitude);
      if (!mounted || req != _reverseReq) return;
      setState(() {
        _address = r;
        _resolving = false;
        _addressError = r == null ? 'No address here' : null;
      });
    } catch (e) {
      if (!mounted || req != _reverseReq) return;
      setState(() {
        _resolving = false;
        _address = null;
        _addressError = 'Address lookup failed · you can still use the pin';
      });
    }
  }

  Future<void> _runSearch() async {
    final q = _search.text.trim();
    if (q.length < 3) return;
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    try {
      final r = await ref.read(geocoderProvider).search(q);
      if (!mounted) return;
      setState(() => _results = r);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _goTo(LatLng p, {double zoom = 17}) {
    _map.move(p, zoom);
    _onMoved(_map.camera, false);
  }

  Future<void> _myLocation() async {
    setState(() => _locating = true);
    try {
      final loc = await ref.read(locationServiceProvider).current();
      _goTo(LatLng(loc.lat, loc.lng));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              key: const Key('map'),
              mapController: _map,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: widget.initial != null ? 16.5 : 13,
                minZoom: 4,
                maxZoom: 19,
                backgroundColor: AppColors.bg,
                onPositionChanged: _onMoved,
                onTap: (_, point) => _goTo(point, zoom: _map.camera.zoom),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.abhranil.commute_planner',
                  maxNativeZoom: 19,
                  tileBuilder: darkModeTileBuilder,
                ),
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  popupBackgroundColor: AppColors.card,
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                    ),
                    const TextSourceAttribution('Search: Nominatim', prependCopyright: false),
                  ],
                ),
              ],
            ),
          ),
          // Centre pin (the map moves underneath it).
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 44),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: AppColors.amber,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          // Search bar + results.
          Positioned(
            left: 16,
            right: 16,
            top: top + 12,
            child: Column(
              children: [
                Row(
                  children: [
                    Material(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(width: 48, height: 48, child: Icon(Icons.close, color: AppColors.text)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const Key('map-search'),
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _runSearch(),
                        style: AppText.body(size: 15),
                        decoration: InputDecoration(
                          hintText: 'Search address or landmark',
                          hintStyle: AppText.body(size: 15, color: AppColors.muted),
                          fillColor: AppColors.card,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                          suffixIcon: _searching
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  key: const Key('map-search-go'),
                                  icon: const Icon(Icons.arrow_forward, color: AppColors.amber),
                                  onPressed: _runSearch,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_results != null) ...[
                  const SizedBox(height: 8),
                  // A Material (not a coloured Container) so the ListTile ink
                  // splashes paint on it instead of being hidden underneath.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Material(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: _results!.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No results', style: AppText.body(color: AppColors.muted)),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _results!.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.line),
                              itemBuilder: (_, i) {
                                final r = _results![i];
                                return ListTile(
                                  key: Key('search-result-$i'),
                                  leading: const Icon(Icons.place_outlined, color: AppColors.amber),
                                  title: Text(r.shortName, style: AppText.body(size: 14, w: FontWeight.w600)),
                                  subtitle: Text(
                                    r.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.body(size: 12, color: AppColors.muted),
                                  ),
                                  onTap: () {
                                    setState(() => _results = null);
                                    _goTo(LatLng(r.lat, r.lng));
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // My location.
          Positioned(
            right: 16,
            bottom: 206,
            child: FloatingActionButton.small(
              key: const Key('my-location'),
              heroTag: 'my-location',
              backgroundColor: AppColors.card,
              foregroundColor: AppColors.text,
              onPressed: _locating ? null : _myLocation,
              child: _locating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),
          // Selected location card.
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181B1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PIN LOCATION', style: AppText.eyebrow()),
                  const SizedBox(height: 6),
                  Text(
                    key: const Key('picked-address'),
                    _resolving && _address == null
                        ? 'Looking up address…'
                        : _address?.shortName ?? _addressError ?? 'Move the map to place the pin',
                    style: AppText.body(size: 16, w: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}'
                    '${_resolving ? ' · updating…' : ''}',
                    style: AppText.body(size: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('use-location'),
                    onPressed: () => Navigator.of(context).pop(
                      PickedLocation(
                        _center.latitude,
                        _center.longitude,
                        address: _resolving ? null : _address?.shortName,
                        fullAddress: _resolving ? null : _address?.displayName,
                      ),
                    ),
                    child: const Text('Use this location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
