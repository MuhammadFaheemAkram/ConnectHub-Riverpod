import 'package:connect_hub_riverpod/core/common/result.dart';
import 'package:connect_hub_riverpod/domain/repository/post_repository.dart';

/// Publishes a post by the signed-in user. The text is trimmed, and an empty
/// image URL means no image.
class CreatePostUseCase {
  const CreatePostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call({required String content, String imageUrl = ''}) {
    final url = imageUrl.trim();
    return _posts.createPost(
      content: content.trim(),
      imageUrl: url.isEmpty ? null : url,
    );
  }
}
