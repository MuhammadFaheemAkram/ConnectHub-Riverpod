import 'dart:async';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/common/form_status.dart';
import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/features/create_post/create_post_controller.dart';
import 'package:connect_hub_riverpod/features/create_post/create_post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/fakes/fake_post_repository.dart';

void main() {
  late FakePostRepository posts;
  late ProviderContainer container;

  setUp(() {
    posts = FakePostRepository();
    container = testContainer(
      overrides: [postRepositoryProvider.overrideWithValue(posts)],
    );
    // Keep the auto-dispose form alive for the whole test, as the page does.
    container.listen(createPostControllerProvider, (_, _) {});
  });

  tearDown(() => posts.dispose());

  CreatePostController form() =>
      container.read(createPostControllerProvider.notifier);
  CreatePostState state() => container.read(createPostControllerProvider);

  group('validation', () {
    test('an untouched form shows no error, and Post is disabled', () {
      expect(state().contentError, isNull);
      expect(state().imageUrlError, isNull);
      expect(state().canSubmit, isFalse);
      expect(state().hasDraft, isFalse);
    });

    test('blank and too long text say why', () {
      form().contentChanged('   ');
      expect(state().contentError, 'Write something to post.');

      form().contentChanged('a' * 281);
      expect(state().contentError, 'Posts can be at most 280 characters.');
      expect(state().length, 281);
      expect(state().canSubmit, isFalse);
    });

    test('a bad image URL says why; a good one or none is fine', () {
      form()
        ..contentChanged('Hello')
        ..imageUrlChanged('picsum.photos');
      expect(state().imageUrlError, 'Enter a valid image URL.');
      expect(state().canSubmit, isFalse);

      form().imageUrlChanged('https://picsum.photos/600');
      expect(state().canSubmit, isTrue);
    });

    test('text is a draft worth a "Discard post?"', () {
      form().contentChanged('Half a thought');

      expect(state().hasDraft, isTrue);
    });
  });

  group('submit', () {
    test('submitting, then success, with trimmed values', () async {
      posts.createGate = Completer<void>();
      form()
        ..contentChanged('  Hello  ')
        ..imageUrlChanged('  ');

      final submitting = form().submit();
      expect(state().status, FormStatus.submitting);
      expect(state().canSubmit, isFalse);

      posts.createGate!.complete();
      await submitting;
      expect(state().status, FormStatus.success);
      expect(posts.createCalls, [(content: 'Hello', imageUrl: null)]);
    });

    test("a failure keeps the input and shows the server's message", () async {
      posts.createResult = const Err(NetworkException());
      form().contentChanged('Hello');

      await form().submit();

      expect(state().status, FormStatus.failure);
      expect(state().errorMessage, const NetworkException().message);
      expect(state().content, 'Hello');
    });

    test('editing after a failure clears the error', () async {
      posts.createResult = const Err(NetworkException());
      form().contentChanged('Hello');
      await form().submit();

      form().contentChanged('Hello!');

      expect(state().status, FormStatus.idle);
      expect(state().errorMessage, isNull);
    });

    test('an invalid form, or a second tap while posting, sends '
        'nothing', () async {
      await form().submit();
      expect(posts.createCalls, isEmpty);

      posts.createGate = Completer<void>();
      form().contentChanged('Hello');
      final first = form().submit();
      await form().submit();
      posts.createGate!.complete();
      await first;

      expect(posts.createCalls, hasLength(1));
    });
  });

  test('auto-dispose: the draft goes with the page', () async {
    final page = ProviderContainer.test(
      overrides: [postRepositoryProvider.overrideWithValue(posts)],
    );
    final open = page.listen(createPostControllerProvider, (_, _) {});
    page.read(createPostControllerProvider.notifier).contentChanged('Draft');

    open.close();
    await pumpEventQueue();

    expect(page.read(createPostControllerProvider).content, isEmpty);
  });
}
