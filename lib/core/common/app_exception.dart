/// The app's error vocabulary.
///
/// Every failure that can reach the UI is one of these types, and each carries
/// a user-facing [message], so screens render a small, stable set of error
/// states instead of raw exceptions.
///
/// `sealed` lets the compiler check that a `switch` over an [AppException]
/// handles every subtype. They are `Exception`s, not `Error`s: something that
/// may work next time, not a bug (Riverpod's default retry tells the two
/// apart too; see `app/retry_policy.dart`).
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Copy that is safe to show to the user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The (fake) network call failed.
final class NetworkException extends AppException {
  const NetworkException()
    : super('Something went wrong with your connection. Please try again.');
}

/// The requested item does not exist.
final class NotFoundException extends AppException {
  const NotFoundException()
    : super("We couldn't find what you were looking for.");
}

/// The data could not be decoded (malformed JSON or unexpected types).
final class DataFormatException extends AppException {
  const DataFormatException()
    : super('We received an unexpected response. Please try again.');
}

/// Anything unexpected that isn't one of the cases above.
final class UnknownException extends AppException {
  const UnknownException() : super('Something went wrong. Please try again.');
}
