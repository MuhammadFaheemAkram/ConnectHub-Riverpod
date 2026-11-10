import 'package:connect_hub_riverpod/di/data_providers.dart';
import 'package:connect_hub_riverpod/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/clear_recent_searches_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/create_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/delete_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/like_comment_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/load_more_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/mark_all_notifications_read_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/mark_notification_read_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_notifications_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/refresh_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/save_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/save_recent_search_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/search_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_feed_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_notifications_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_post_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_recent_searches_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_search_people_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_search_posts_use_case.dart';
import 'package:connect_hub_riverpod/domain/usecase/watch_unread_notification_count_use_case.dart';
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

@riverpod
SearchUseCase searchUseCase(Ref ref) =>
    SearchUseCase(ref.watch(searchRepositoryProvider));

@riverpod
WatchSearchPeopleUseCase watchSearchPeopleUseCase(Ref ref) =>
    WatchSearchPeopleUseCase(ref.watch(searchRepositoryProvider));

@riverpod
WatchSearchPostsUseCase watchSearchPostsUseCase(Ref ref) =>
    WatchSearchPostsUseCase(ref.watch(searchRepositoryProvider));

@riverpod
WatchRecentSearchesUseCase watchRecentSearchesUseCase(Ref ref) =>
    WatchRecentSearchesUseCase(ref.watch(searchRepositoryProvider));

@riverpod
SaveRecentSearchUseCase saveRecentSearchUseCase(Ref ref) =>
    SaveRecentSearchUseCase(ref.watch(searchRepositoryProvider));

@riverpod
ClearRecentSearchesUseCase clearRecentSearchesUseCase(Ref ref) =>
    ClearRecentSearchesUseCase(ref.watch(searchRepositoryProvider));

@riverpod
WatchNotificationsUseCase watchNotificationsUseCase(Ref ref) =>
    WatchNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
WatchUnreadNotificationCountUseCase watchUnreadNotificationCountUseCase(
  Ref ref,
) => WatchUnreadNotificationCountUseCase(
  ref.watch(notificationRepositoryProvider),
);

@riverpod
RefreshNotificationsUseCase refreshNotificationsUseCase(Ref ref) =>
    RefreshNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkNotificationReadUseCase markNotificationReadUseCase(Ref ref) =>
    MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase(Ref ref) =>
    MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider));
