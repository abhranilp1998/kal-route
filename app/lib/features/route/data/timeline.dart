import 'route_result.dart';

enum NodeKind { leave, setOff, stop, arrive }

class TimelineNode {
  const TimelineNode(this.kind, this.time, this.title, {this.subtitle, this.mode});
  final NodeKind kind;
  final DateTime time;
  final String title;
  final String? subtitle;

  /// Mode of the leg that starts here (for the node colour), null for ends.
  final String? mode;
}

class TimelineSegment {
  const TimelineSegment.buffer(this.minutes) : leg = null;
  const TimelineSegment.leg(RouteLeg this.leg) : minutes = 0;
  final RouteLeg? leg;
  final int minutes;
  bool get isBuffer => leg == null;
  int get durationMinutes => leg?.minutes ?? minutes;
}

/// Nodes interleaved with segments: node0, seg0, node1, seg1, ..., nodeN.
class Timeline {
  const Timeline(this.nodes, this.segments) : assert(nodes.length == segments.length + 1);
  final List<TimelineNode> nodes;
  final List<TimelineSegment> segments;
}

/// Builds the route timeline so it agrees with the card and notification:
/// it starts at the trip's leave time, shows the buffer as its own segment,
/// then each leg, and ends at the route's arrival.
Timeline buildTimeline({
  required RouteResult route,
  required DateTime? leaveAt,
  required int bufferMinutes,
  required String startName,
  required String endName,
  String? startSubtitle,
  DateTime? arriveBy,
}) {
  final nodes = <TimelineNode>[];
  final segs = <TimelineSegment>[];
  final legs = route.legs;
  final firstMode = legs.isEmpty ? null : legs.first.mode;
  final effectiveLeave = leaveAt ?? route.leaveAt.subtract(Duration(minutes: bufferMinutes));
  final buffer = route.leaveAt.difference(effectiveLeave).inMinutes;

  nodes.add(TimelineNode(NodeKind.leave, effectiveLeave, 'Leave $startName',
      subtitle: startSubtitle, mode: buffer > 0 ? null : firstMode));
  if (buffer > 0) {
    segs.add(TimelineSegment.buffer(buffer));
    final firstLeg = legs.isEmpty ? null : legs.first;
    nodes.add(TimelineNode(NodeKind.setOff, route.leaveAt, 'Set off',
        subtitle: firstLeg == null
            ? null
            : firstLeg.isWalk
                ? 'walk to ${firstLeg.to}'
                : '${firstLeg.line ?? firstLeg.mode} from ${firstLeg.from}',
        mode: firstMode));
  }

  var t = route.leaveAt;
  for (var i = 0; i < legs.length; i++) {
    final l = legs[i];
    final start = (l.departAt != null && l.departAt!.isAfter(t)) ? l.departAt! : t;
    t = start.add(Duration(minutes: l.minutes));
    segs.add(TimelineSegment.leg(l));
    if (i == legs.length - 1) break;
    final next = legs[i + 1];
    nodes.add(TimelineNode(NodeKind.stop, t, l.isWalk ? next.from : l.to,
        subtitle: !next.isWalk && next.headsign != null ? 'towards ${next.headsign}' : null, mode: next.mode));
  }
  final early = arriveBy?.difference(route.arriveAt).inMinutes;
  nodes.add(TimelineNode(NodeKind.arrive, route.arriveAt, endName,
      subtitle: arriveBy == null
          ? null
          : (early != null && early > 0)
              ? '$early min before ${_hm(arriveBy)}'
              : 'need to be there by ${_hm(arriveBy)}'));
  return Timeline(nodes, segs);
}

String _hm(DateTime t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
