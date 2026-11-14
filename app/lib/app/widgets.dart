import 'package:material_ui/material_ui.dart';

import '../features/route/data/route_result.dart';
import 'theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

/// Thin bar showing how much of the trip each mode takes. Walk = dashed.
class ModeBar extends StatelessWidget {
  const ModeBar({super.key, required this.legs, this.height = 6});
  final List<RouteLeg> legs;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < legs.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  flex: legs[i].minutes.clamp(1, 999),
                  child: legs[i].isWalk
                      ? CustomPaint(painter: _DashPainter(AppColors.walk))
                      : ColoredBox(color: AppColors.forMode(legs[i].mode)),
                ),
              ],
            ],
          ),
        ),
      );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 4, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class ModeDot extends StatelessWidget {
  const ModeDot({super.key, required this.mode, required this.label});
  final String mode;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: AppColors.forMode(mode), shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppText.body(size: 12, color: AppColors.muted)),
      ]);
}

String modeLabel(String m) => switch (m) {
      'METRO' => 'metro',
      'BUS' => 'bus',
      'AUTO' => 'auto',
      'FERRY' => 'ferry',
      'TRAIN' => 'train',
      'TRAM' => 'tram',
      'WALK' => 'walk',
      _ => m.toLowerCase(),
    };

/// Distinct modes in order of appearance.
List<String> modesOf(List<RouteLeg> legs) {
  final out = <String>[];
  for (final l in legs) {
    if (!out.contains(l.mode)) out.add(l.mode);
  }
  return out;
}

/// Fade + slide up 8px on first build, with an optional stagger delay.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay; // ms

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 320 + delay),
        curve: Interval(delay / (320 + delay), 1, curve: Curves.easeOutCubic),
        builder: (context, t, child) =>
            Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child)),
        child: child,
      );
}

class ExampleDataTag extends StatelessWidget {
  const ExampleDataTag({super.key, this.text = 'EXAMPLE DATA'});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(text, style: AppText.eyebrow(AppColors.faint).copyWith(fontSize: 10)));
}

class IconSquare extends StatelessWidget {
  const IconSquare({super.key, required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Tooltip(
            message: tooltip ?? '',
            child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: AppColors.text)),
          ),
        ),
      );
}
