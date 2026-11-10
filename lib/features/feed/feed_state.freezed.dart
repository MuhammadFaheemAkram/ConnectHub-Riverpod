// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedState {

/// The cached window, newest first.
 List<Post> get posts; LoadMoreStatus get loadMore;/// A one-off SnackBar. The page shows it from `ref.listen` and then
/// calls `messageShown()`, so it shows once (Correctness Rule 3).
 String? get message;
/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedStateCopyWith<FeedState> get copyWith => _$FeedStateCopyWithImpl<FeedState>(this as FeedState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeedState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedState&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.loadMore, _this.loadMore) || other.loadMore == _this.loadMore)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as FeedState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.posts),_this.loadMore,_this.message);
}

@override
String toString() {
  final _this = this as FeedState;
  return 'FeedState(posts: ${_this.posts}, loadMore: ${_this.loadMore}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $FeedStateCopyWith<$Res>  {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) _then) = _$FeedStateCopyWithImpl;
@useResult
$Res call({
 List<Post> posts, LoadMoreStatus loadMore, String? message
});




}
/// @nodoc
class _$FeedStateCopyWithImpl<$Res>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._self, this._then);

  final FeedState _self;
  final $Res Function(FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? loadMore = null,Object? message = freezed,}) {
  return _then(FeedState(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedState].
extension FeedStatePatterns on FeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedState value)  $default,){
final _that = this;
switch (_that) {
case _FeedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Post> posts,  LoadMoreStatus loadMore,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.posts,_that.loadMore,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Post> posts,  LoadMoreStatus loadMore,  String? message)  $default,) {final _that = this;
switch (_that) {
case _FeedState():
return $default(_that.posts,_that.loadMore,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Post> posts,  LoadMoreStatus loadMore,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.posts,_that.loadMore,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _FeedState implements FeedState {
  const _FeedState({required  List<Post> posts, this.loadMore = LoadMoreStatus.idle, this.message}): _posts = posts;
  

/// The cached window, newest first.
 final  List<Post> _posts;
/// The cached window, newest first.
@override List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override@JsonKey() final  LoadMoreStatus loadMore;
/// A one-off SnackBar. The page shows it from `ref.listen` and then
/// calls `messageShown()`, so it shows once (Correctness Rule 3).
@override final  String? message;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedStateCopyWith<_FeedState> get copyWith => __$FeedStateCopyWithImpl<_FeedState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedState&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.loadMore, loadMore) || other.loadMore == loadMore)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),loadMore,message);
}

@override
String toString() {
    return 'FeedState(posts: $posts, loadMore: $loadMore, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FeedStateCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory _$FeedStateCopyWith(_FeedState value, $Res Function(_FeedState) _then) = __$FeedStateCopyWithImpl;
@override @useResult
$Res call({
 List<Post> posts, LoadMoreStatus loadMore, String? message
});




}
/// @nodoc
class __$FeedStateCopyWithImpl<$Res>
    implements _$FeedStateCopyWith<$Res> {
  __$FeedStateCopyWithImpl(this._self, this._then);

  final _FeedState _self;
  final $Res Function(_FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? loadMore = null,Object? message = freezed,}) {
  return _then(_FeedState(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
