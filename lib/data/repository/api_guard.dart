import 'dart:developer' as developer;

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';

/// Runs an API call for a repository and turns its outcome into a [Result].
///
/// The app's own failures ([AppException]s) become an `Err` with their
/// message. Anything else is unexpected: it is logged, and the UI gets a
/// generic message instead of a raw exception. `Error`s (programming
/// mistakes) are not caught, so tests still see them.
///
/// ConnectHub-Flutter's guard also expired the session on a 401. This
/// edition has no sign-in, so a plain function is enough.
Future<Result<T>> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return Ok(await call());
  } on AppException catch (exception) {
    return Err(exception);
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Unexpected exception in an API call',
      error: error,
      stackTrace: stackTrace,
      name: 'guardApiCall',
    );
    return const Err(UnknownException());
  }
}
