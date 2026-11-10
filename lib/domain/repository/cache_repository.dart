/// The cache as a whole: Settings → Clear cache.
abstract interface class CacheRepository {
  /// Deletes the cached copy of the server's data. It keeps what can't be
  /// fetched again or belongs to the device: saved posts (and their
  /// authors), the signed-in user, recent searches, the settings.
  Future<void> clearCache();
}
