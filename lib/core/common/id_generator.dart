import 'dart:math';

/// Generates random ids, for the fake server's new posts and comments.
///
/// Injected rather than called statically, so tests can pass a seeded
/// [Random] and get repeatable ids.
class IdGenerator {
  IdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// An id such as `c_3fa94c1e` for `next('c')`.
  String next(String prefix) => '${prefix}_${hex(8)}';

  /// [length] random hexadecimal characters.
  String hex(int length) => List.generate(
    length,
    (_) => _random.nextInt(16).toRadixString(16),
  ).join();
}
