import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Debounce through disposal (Correctness Rule 5).
extension DebounceRef on Ref {
  /// Waits [delay], unless this provider is disposed first. Then the timer
  /// is cancelled (none outlives the provider, or a test) and the wait
  /// never ends, so the code after it never runs.
  ///
  /// Never ending, rather than ending with an error: the provider is gone,
  /// so nothing would handle that error, and it would surface as an
  /// uncaught one. A future nobody waits for any more is simply collected.
  ///
  /// A family keyed by the query does the rest: typing a new query moves
  /// the screen to a new provider, the old one loses its last listener and
  /// is disposed, and its pending wait is cancelled. No `restartable()`
  /// transformer, no stream library: the newest query wins because it is
  /// the only one still watched.
  Future<void> debounce(Duration delay) {
    final waited = Completer<void>();
    final timer = Timer(delay, waited.complete);
    onDispose(timer.cancel);
    return waited.future;
  }
}
