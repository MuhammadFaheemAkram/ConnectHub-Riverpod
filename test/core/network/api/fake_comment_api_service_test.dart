import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/api/comment_api_service.dart';
import 'package:connect_hub_riverpod/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';

// The comment endpoints as the app builds them: through the providers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  CommentApiService api() => container.read(commentApiServiceProvider);

  setUp(() => container = testContainer());

  test('comments are added, liked and deleted as the demo user', () async {
    final added = await api().addComment('p4', 'Great point!');
    expect(added.author.id, 'u_demo');

    final liked = await api().setLiked(added.id, liked: true);
    expect(liked.isLiked, isTrue);

    await api().deleteComment(added.id);
    expect(await api().getComments('p4'), isEmpty);
  });

  test("someone else's comment can't be deleted", () async {
    await expectLater(
      api().deleteComment('c1'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('new ids are repeatable in tests (a seeded generator)', () async {
    final first = await api().addComment('p4', 'One');
    final other = testContainer().read(commentApiServiceProvider);

    expect((await other.addComment('p4', 'One')).id, first.id);
  });
}
