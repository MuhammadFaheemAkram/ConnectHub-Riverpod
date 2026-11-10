import 'package:characters/characters.dart';

/// Form validation rules. Each returns an error message, or `null` when the
/// value is valid.
///
/// Pure functions, shared by the forms and the fake server, and tested rule
/// by rule. Lengths are counted in characters as people see them: an emoji
/// counts as one.
abstract final class Validators {
  static const postMaxLength = 280;
  static const commentMaxLength = 500;

  /// 1–280 characters once trimmed.
  static String? postContent(String value) {
    if (value.trim().isEmpty) return 'Write something to post.';
    if (lengthOf(value.trim()) > postMaxLength) {
      return 'Posts can be at most $postMaxLength characters.';
    }
    return null;
  }

  /// Optional: empty is fine; anything else must be an `http`/`https` URL
  /// with a host.
  static String? imageUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWebUrl ? null : 'Enter a valid image URL.';
  }

  /// Not blank, at most 500 characters once trimmed. The comment field
  /// enforces the length as you type; the server checks both rules.
  static String? comment(String value) {
    if (value.trim().isEmpty) return 'Write a comment.';
    if (lengthOf(value.trim()) > commentMaxLength) {
      return 'Comments can be at most $commentMaxLength characters.';
    }
    return null;
  }

  /// The length a person counts (grapheme clusters), not UTF-16 code units:
  /// "👍🏽" is one character, while `String.length` says 4.
  static int lengthOf(String value) => value.characters.length;
}
