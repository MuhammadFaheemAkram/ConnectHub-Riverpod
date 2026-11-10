import 'package:connect_hub_riverpod/core/common/clock_provider.dart';
import 'package:connect_hub_riverpod/core/common/relative_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A timestamp shown as "5m" and read out as "5 minutes ago".
///
/// The current time comes from [clockProvider], the same clock the fake
/// server and the repositories use, so one test override fixes the time for
/// everything. (ConnectHub-Flutter's widget used the zone's `clock` instead:
/// a widget couldn't take dependencies from get_it's container. With
/// Riverpod, a widget reads providers like any other code.)
///
/// `ref.watch` in `build` (Correctness Rule 1): a test that overrides the
/// clock gets its time here too.
class RelativeTimeText extends ConsumerWidget {
  const RelativeTimeText(this.time, {super.key, this.style});

  final DateTime time;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    return Semantics(
      label: RelativeTime.spoken(time, now: now),
      excludeSemantics: true,
      child: Text(RelativeTime.short(time, now: now), style: style),
    );
  }
}
