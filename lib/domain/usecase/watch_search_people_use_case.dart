import 'package:connect_hub_riverpod/domain/model/user.dart';
import 'package:connect_hub_riverpod/domain/repository/search_repository.dart';

/// The people a search found, live from the cache, in the server's order.
class WatchSearchPeopleUseCase {
  const WatchSearchPeopleUseCase(this._search);

  final SearchRepository _search;

  Stream<List<User>> call(List<String> ids) => _search.watchPeople(ids);
}
