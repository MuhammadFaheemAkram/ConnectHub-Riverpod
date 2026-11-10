import 'package:connect_hub_riverpod/core/database/daos/cache_dao.dart';
import 'package:connect_hub_riverpod/domain/repository/cache_repository.dart';

/// Clear cache: the cached copy of the server's data goes (see
/// `CacheDao.clearServerData`).
///
/// Telling the screens is not this repository's job: in this edition, the
/// screens that show server data *watch* the cache's epoch
/// (`cacheEpochProvider`), and the provider that clears also bumps it.
class CacheRepositoryImpl implements CacheRepository {
  CacheRepositoryImpl(this._cache, {required String signedInUserId})
    : _me = signedInUserId;

  final CacheDao _cache;
  final String _me;

  @override
  Future<void> clearCache() => _cache.clearServerData(keepUserId: _me);
}
