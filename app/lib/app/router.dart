import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/places/ui/places_screen.dart';
import '../features/plan/ui/tomorrow_screen.dart';
import '../features/route/ui/route_detail_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import 'theme.dart';

final router = GoRouter(
  initialLocation: '/tomorrow',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/tomorrow', pageBuilder: (c, s) => const NoTransitionPage(child: TomorrowScreen())),
        GoRoute(path: '/places', pageBuilder: (c, s) => const NoTransitionPage(child: PlacesScreen())),
        GoRoute(path: '/settings', pageBuilder: (c, s) => const NoTransitionPage(child: SettingsScreen())),
      ],
    ),
    GoRoute(
      path: '/route/:id',
      builder: (c, s) => RouteDetailScreen(tripId: int.parse(s.pathParameters['id']!)),
    ),
  ],
);

class _Shell extends StatelessWidget {
  const _Shell({required this.location, required this.child});
  final String location;
  final Widget child;

  static const _tabs = ['/tomorrow', '/places', '/settings'];

  @override
  Widget build(BuildContext context) {
    final idx = _tabs.indexWhere(location.startsWith).clamp(0, 2);
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: NavigationBar(
          selectedIndex: idx,
          height: 68,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Tomorrow'),
            NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Places'),
            NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
