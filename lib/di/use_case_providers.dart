import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/create_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/delete_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/like_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/load_more_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/save_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_post_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'use_case_providers.g.dart';

// Use cases are plain classes (the domain layer knows nothing of Riverpod),
// each behind a provider. They hold no state, so they keep the default:
// auto-dispose. Creating one is a single allocation over repositories that
// are kept alive anyway.
//
// A notifier reads them with `ref.read(…UseCaseProvider)` inside a method:
// it calls the use case once, and doesn't need to rebuild if it changes.

@riverpod
WatchFeedUseCase watchFeedUseCase(Ref ref) =>
    WatchFeedUseCase(ref.watch(feedRepositoryProvider));

@riverpod
RefreshFeedUseCase refreshFeedUseCase(Ref ref) =>
    RefreshFeedUseCase(ref.watch(feedRepositoryProvider));

@riverpod
LoadMoreFeedUseCase loadMoreFeedUseCase(Ref ref) =>
    LoadMoreFeedUseCase(ref.watch(feedRepositoryProvider));

@riverpod
LikePostUseCase likePostUseCase(Ref ref) =>
    LikePostUseCase(ref.watch(postRepositoryProvider));

@riverpod
SavePostUseCase savePostUseCase(Ref ref) =>
    SavePostUseCase(ref.watch(postRepositoryProvider));

@riverpod
WatchPostUseCase watchPostUseCase(Ref ref) =>
    WatchPostUseCase(ref.watch(postRepositoryProvider));

@riverpod
RefreshPostUseCase refreshPostUseCase(Ref ref) =>
    RefreshPostUseCase(ref.watch(postRepositoryProvider));

@riverpod
CreatePostUseCase createPostUseCase(Ref ref) =>
    CreatePostUseCase(ref.watch(postRepositoryProvider));

@riverpod
WatchCommentsUseCase watchCommentsUseCase(Ref ref) =>
    WatchCommentsUseCase(ref.watch(commentRepositoryProvider));

@riverpod
RefreshCommentsUseCase refreshCommentsUseCase(Ref ref) =>
    RefreshCommentsUseCase(ref.watch(commentRepositoryProvider));

@riverpod
AddCommentUseCase addCommentUseCase(Ref ref) =>
    AddCommentUseCase(ref.watch(commentRepositoryProvider));

@riverpod
DeleteCommentUseCase deleteCommentUseCase(Ref ref) =>
    DeleteCommentUseCase(ref.watch(commentRepositoryProvider));

@riverpod
LikeCommentUseCase likeCommentUseCase(Ref ref) =>
    LikeCommentUseCase(ref.watch(commentRepositoryProvider));
