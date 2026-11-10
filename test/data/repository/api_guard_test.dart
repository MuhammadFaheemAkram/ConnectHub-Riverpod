import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/data/repository/api_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a value becomes Ok', () async {
    expect(
      await guardApiCall(() async => 42),
      isA<Ok<int>>().having((ok) => ok.value, 'value', 42),
    );
  });

  test(
    "the app's own failures keep their type, and so their message",
    () async {
      final result = await guardApiCall<int>(
        () async => throw const NetworkException(),
      );

      expect(
        result,
        isA<Err<int>>().having(
          (err) => err.exception,
          'exception',
          isA<NetworkException>(),
        ),
      );
    },
  );

  test('any other exception becomes UnknownException, never a raw '
      'message', () async {
    final result = await guardApiCall<int>(
      () async => throw const FormatException('Invalid cursor'),
    );

    expect(
      result,
      isA<Err<int>>().having(
        (err) => err.exception,
        'exception',
        isA<UnknownException>(),
      ),
    );
  });

  test('an Error (a bug) is not caught', () async {
    await expectLater(
      guardApiCall<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
