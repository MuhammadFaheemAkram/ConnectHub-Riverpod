import 'package:connect_hub_riverpod/domain/repository/cache_repository.dart';

/// Deletes the cached server data; saved posts, recent searches and settings
/// stay.
class ClearCacheUseCase {
  const ClearCacheUseCase(this._cache);

  final CacheRepository _cache;

  Future<void> call() => _cache.clearCache();
}
