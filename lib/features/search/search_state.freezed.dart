// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchState {

/// As typed; trimmed when searched.
 String get query; SearchScope get scope;/// A one-off SnackBar (a like or a save that failed in the results).
 String? get message;
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateCopyWith<SearchState> get copyWith => _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as SearchState;
  return Object.hash(runtimeType,_this.query,_this.scope,_this.message);
}

@override
String toString() {
  final _this = this as SearchState;
  return 'SearchState(query: ${_this.query}, scope: ${_this.scope}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res>  {
  factory $SearchStateCopyWith(SearchState value, $Res Function(SearchState) _then) = _$SearchStateCopyWithImpl;
@useResult
$Res call({
 String query, SearchScope scope, String? message
});




}
/// @nodoc
class _$SearchStateCopyWithImpl<$Res>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? scope = null,Object? message = freezed,}) {
  return _then(SearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as SearchScope,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchState value)  $default,){
final _that = this;
switch (_that) {
case _SearchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  SearchScope scope,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.query,_that.scope,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  SearchScope scope,  String? message)  $default,) {final _that = this;
switch (_that) {
case _SearchState():
return $default(_that.query,_that.scope,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  SearchScope scope,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.query,_that.scope,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SearchState extends SearchState {
  const _SearchState({this.query = '', this.scope = SearchScope.all, this.message}): super._();
  

/// As typed; trimmed when searched.
@override@JsonKey() final  String query;
@override@JsonKey() final  SearchScope scope;
/// A one-off SnackBar (a like or a save that failed in the results).
@override final  String? message;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateCopyWith<_SearchState> get copyWith => __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchState&&(identical(other.query, query) || other.query == query)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,scope,message);
}

@override
String toString() {
    return 'SearchState(query: $query, scope: $scope, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(_SearchState value, $Res Function(_SearchState) _then) = __$SearchStateCopyWithImpl;
@override @useResult
$Res call({
 String query, SearchScope scope, String? message
});




}
/// @nodoc
class __$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? scope = null,Object? message = freezed,}) {
  return _then(_SearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as SearchScope,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SearchResultsView {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResultsView);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SearchResultsView()';
}


}

/// @nodoc
class $SearchResultsViewCopyWith<$Res>  {
$SearchResultsViewCopyWith(SearchResultsView _, $Res Function(SearchResultsView) __);
}


/// Adds pattern-matching-related methods to [SearchResultsView].
extension SearchResultsViewPatterns on SearchResultsView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchIdle value)?  idle,TResult Function( SearchSearching value)?  searching,TResult Function( SearchFound value)?  found,TResult Function( SearchFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle(_that);case SearchSearching() when searching != null:
return searching(_that);case SearchFound() when found != null:
return found(_that);case SearchFailed() when failed != null:
return failed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchIdle value)  idle,required TResult Function( SearchSearching value)  searching,required TResult Function( SearchFound value)  found,required TResult Function( SearchFailed value)  failed,}){
final _that = this;
switch (_that) {
case SearchIdle():
return idle(_that);case SearchSearching():
return searching(_that);case SearchFound():
return found(_that);case SearchFailed():
return failed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchIdle value)?  idle,TResult? Function( SearchSearching value)?  searching,TResult? Function( SearchFound value)?  found,TResult? Function( SearchFailed value)?  failed,}){
final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle(_that);case SearchSearching() when searching != null:
return searching(_that);case SearchFound() when found != null:
return found(_that);case SearchFailed() when failed != null:
return failed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( SearchResults? previous)?  searching,TResult Function( SearchResults results)?  found,TResult Function( Object error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle();case SearchSearching() when searching != null:
return searching(_that.previous);case SearchFound() when found != null:
return found(_that.results);case SearchFailed() when failed != null:
return failed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( SearchResults? previous)  searching,required TResult Function( SearchResults results)  found,required TResult Function( Object error)  failed,}) {final _that = this;
switch (_that) {
case SearchIdle():
return idle();case SearchSearching():
return searching(_that.previous);case SearchFound():
return found(_that.results);case SearchFailed():
return failed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( SearchResults? previous)?  searching,TResult? Function( SearchResults results)?  found,TResult? Function( Object error)?  failed,}) {final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle();case SearchSearching() when searching != null:
return searching(_that.previous);case SearchFound() when found != null:
return found(_that.results);case SearchFailed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class SearchIdle implements SearchResultsView {
  const SearchIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SearchResultsView.idle()';
}


}




/// @nodoc


class SearchSearching implements SearchResultsView {
  const SearchSearching({this.previous});
  

 final  SearchResults? previous;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSearchingCopyWith<SearchSearching> get copyWith => _$SearchSearchingCopyWithImpl<SearchSearching>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSearching&&(identical(other.previous, previous) || other.previous == previous));
}


@override
int get hashCode {
    return Object.hash(runtimeType,previous);
}

@override
String toString() {
    return 'SearchResultsView.searching(previous: $previous)';
}


}

/// @nodoc
abstract mixin class $SearchSearchingCopyWith<$Res> implements $SearchResultsViewCopyWith<$Res> {
  factory $SearchSearchingCopyWith(SearchSearching value, $Res Function(SearchSearching) _then) = _$SearchSearchingCopyWithImpl;
@useResult
$Res call({
 SearchResults? previous
});


$SearchResultsCopyWith<$Res>? get previous;

}
/// @nodoc
class _$SearchSearchingCopyWithImpl<$Res>
    implements $SearchSearchingCopyWith<$Res> {
  _$SearchSearchingCopyWithImpl(this._self, this._then);

  final SearchSearching _self;
  final $Res Function(SearchSearching) _then;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? previous = freezed,}) {
  return _then(SearchSearching(
previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as SearchResults?,
  ));
}

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<$Res>? get previous {
    if (_self.previous == null) {
    return null;
  }

  return $SearchResultsCopyWith<$Res>(_self.previous!, (value) {
    return _then(_self.copyWith(previous: value));
  });
}
}

/// @nodoc


class SearchFound implements SearchResultsView {
  const SearchFound(this.results);
  

 final  SearchResults results;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFoundCopyWith<SearchFound> get copyWith => _$SearchFoundCopyWithImpl<SearchFound>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFound&&(identical(other.results, results) || other.results == results));
}


@override
int get hashCode {
    return Object.hash(runtimeType,results);
}

@override
String toString() {
    return 'SearchResultsView.found(results: $results)';
}


}

/// @nodoc
abstract mixin class $SearchFoundCopyWith<$Res> implements $SearchResultsViewCopyWith<$Res> {
  factory $SearchFoundCopyWith(SearchFound value, $Res Function(SearchFound) _then) = _$SearchFoundCopyWithImpl;
@useResult
$Res call({
 SearchResults results
});


$SearchResultsCopyWith<$Res> get results;

}
/// @nodoc
class _$SearchFoundCopyWithImpl<$Res>
    implements $SearchFoundCopyWith<$Res> {
  _$SearchFoundCopyWithImpl(this._self, this._then);

  final SearchFound _self;
  final $Res Function(SearchFound) _then;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? results = null,}) {
  return _then(SearchFound(
null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as SearchResults,
  ));
}

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<$Res> get results {
  
  return $SearchResultsCopyWith<$Res>(_self.results, (value) {
    return _then(_self.copyWith(results: value));
  });
}
}

/// @nodoc


class SearchFailed implements SearchResultsView {
  const SearchFailed(this.error);
  

 final  Object error;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFailedCopyWith<SearchFailed> get copyWith => _$SearchFailedCopyWithImpl<SearchFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailed&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'SearchResultsView.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $SearchFailedCopyWith<$Res> implements $SearchResultsViewCopyWith<$Res> {
  factory $SearchFailedCopyWith(SearchFailed value, $Res Function(SearchFailed) _then) = _$SearchFailedCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class _$SearchFailedCopyWithImpl<$Res>
    implements $SearchFailedCopyWith<$Res> {
  _$SearchFailedCopyWithImpl(this._self, this._then);

  final SearchFailed _self;
  final $Res Function(SearchFailed) _then;

/// Create a copy of SearchResultsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(SearchFailed(
null == error ? _self.error : error ,
  ));
}


}

// dart format on
