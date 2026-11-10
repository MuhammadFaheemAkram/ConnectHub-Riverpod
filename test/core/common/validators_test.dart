import 'package:connect_hub_riverpod/core/common/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('postContent', () {
    test('1–280 characters once trimmed', () {
      expect(Validators.postContent('Hello'), isNull);
      expect(Validators.postContent('a' * 280), isNull);
      expect(Validators.postContent('  ${'a' * 280}  '), isNull);
    });

    test('blank: "Write something to post."', () {
      expect(Validators.postContent(''), 'Write something to post.');
      expect(Validators.postContent(' \n '), 'Write something to post.');
    });

    test('over 280: "Posts can be at most 280 characters."', () {
      expect(
        Validators.postContent('a' * 281),
        'Posts can be at most 280 characters.',
      );
    });

    test('counts what people see: an emoji is one character', () {
      expect(Validators.lengthOf('👍🏽'), 1);
      expect(Validators.postContent('👍🏽' * 280), isNull);
    });
  });

  group('imageUrl', () {
    test('optional: empty is fine', () {
      expect(Validators.imageUrl(''), isNull);
      expect(Validators.imageUrl('   '), isNull);
    });

    test('an absolute http(s) URL with a host', () {
      expect(Validators.imageUrl('https://picsum.photos/600'), isNull);
      expect(Validators.imageUrl('http://example.com/a.png'), isNull);
    });

    test('anything else: "Enter a valid image URL."', () {
      for (final bad in ['picsum.photos/600', 'ftp://x.com/a', 'https://']) {
        expect(
          Validators.imageUrl(bad),
          'Enter a valid image URL.',
          reason: bad,
        );
      }
    });
  });

  group('comment', () {
    test('not blank, at most 500 characters once trimmed', () {
      expect(Validators.comment('Nice!'), isNull);
      expect(Validators.comment('a' * 500), isNull);
      expect(Validators.comment('  '), 'Write a comment.');
      expect(
        Validators.comment('a' * 501),
        'Comments can be at most 500 characters.',
      );
    });
  });
}
