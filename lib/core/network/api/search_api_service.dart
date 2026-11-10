import 'package:connect_hub_riverpod/core/network/dto/search_response_dto.dart';

/// The search endpoint, Retrofit-style. The server leaves the signed-in user
/// out of the people it finds.
abstract interface class SearchApiService {
  /// `GET /search?q=…`: the people and posts matching [query].
  Future<SearchResponseDto> search(String query);
}
