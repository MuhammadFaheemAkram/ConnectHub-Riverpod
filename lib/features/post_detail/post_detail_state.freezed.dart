// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostDetailState {

 Post get post;/// Every comment, oldest first.
 List<Comment> get comments;/// A comment is on its way: Send shows progress.
 bool get isSending;/// Goes up by one each time a comment is sent. The page clears the input
/// and scrolls to the comment when it changes.
 int get sentCount;/// A one-off SnackBar, consumed by `messageShown()`.
 String? get message;
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailStateCopyWith<PostDetailState> get copyWith => _$PostDetailStateCopyWithImpl<PostDetailState>(this as PostDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailState&&(identical(other.post, _this.post) || other.post == _this.post)&&const DeepCollectionEquality().equals(other.comments, _this.comments)&&(identical(other.isSending, _this.isSending) || other.isSending == _this.isSending)&&(identical(other.sentCount, _this.sentCount) || other.sentCount == _this.sentCount)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as PostDetailState;
  return Object.hash(runtimeType,_this.post,const DeepCollectionEquality().hash(_this.comments),_this.isSending,_this.sentCount,_this.message);
}

@override
String toString() {
  final _this = this as PostDetailState;
  return 'PostDetailState(post: ${_this.post}, comments: ${_this.comments}, isSending: ${_this.isSending}, sentCount: ${_this.sentCount}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $PostDetailStateCopyWith<$Res>  {
  factory $PostDetailStateCopyWith(PostDetailState value, $Res Function(PostDetailState) _then) = _$PostDetailStateCopyWithImpl;
@useResult
$Res call({
 Post post, List<Comment> comments, bool isSending, int sentCount, String? message
});


$PostCopyWith<$Res> get post;

}
/// @nodoc
class _$PostDetailStateCopyWithImpl<$Res>
    implements $PostDetailStateCopyWith<$Res> {
  _$PostDetailStateCopyWithImpl(this._self, this._then);

  final PostDetailState _self;
  final $Res Function(PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? comments = null,Object? isSending = null,Object? sentCount = null,Object? message = freezed,}) {
  return _then(PostDetailState(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,sentCount: null == sentCount ? _self.sentCount : sentCount // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostDetailState].
extension PostDetailStatePatterns on PostDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostDetailState value)  $default,){
final _that = this;
switch (_that) {
case _PostDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Post post,  List<Comment> comments,  bool isSending,  int sentCount,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.comments,_that.isSending,_that.sentCount,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Post post,  List<Comment> comments,  bool isSending,  int sentCount,  String? message)  $default,) {final _that = this;
switch (_that) {
case _PostDetailState():
return $default(_that.post,_that.comments,_that.isSending,_that.sentCount,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Post post,  List<Comment> comments,  bool isSending,  int sentCount,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.comments,_that.isSending,_that.sentCount,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PostDetailState implements PostDetailState {
  const _PostDetailState({required this.post,  List<Comment> comments = const <Comment>[], this.isSending = false, this.sentCount = 0, this.message}): _comments = comments;
  

@override final  Post post;
/// Every comment, oldest first.
 final  List<Comment> _comments;
/// Every comment, oldest first.
@override@JsonKey() List<Comment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

/// A comment is on its way: Send shows progress.
@override@JsonKey() final  bool isSending;
/// Goes up by one each time a comment is sent. The page clears the input
/// and scrolls to the comment when it changes.
@override@JsonKey() final  int sentCount;
/// A one-off SnackBar, consumed by `messageShown()`.
@override final  String? message;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostDetailStateCopyWith<_PostDetailState> get copyWith => __$PostDetailStateCopyWithImpl<_PostDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostDetailState&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.comments, _comments)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.sentCount, sentCount) || other.sentCount == sentCount)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,post,const DeepCollectionEquality().hash(_comments),isSending,sentCount,message);
}

@override
String toString() {
    return 'PostDetailState(post: $post, comments: $comments, isSending: $isSending, sentCount: $sentCount, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PostDetailStateCopyWith<$Res> implements $PostDetailStateCopyWith<$Res> {
  factory _$PostDetailStateCopyWith(_PostDetailState value, $Res Function(_PostDetailState) _then) = __$PostDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Post post, List<Comment> comments, bool isSending, int sentCount, String? message
});


@override $PostCopyWith<$Res> get post;

}
/// @nodoc
class __$PostDetailStateCopyWithImpl<$Res>
    implements _$PostDetailStateCopyWith<$Res> {
  __$PostDetailStateCopyWithImpl(this._self, this._then);

  final _PostDetailState _self;
  final $Res Function(_PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? comments = null,Object? isSending = null,Object? sentCount = null,Object? message = freezed,}) {
  return _then(_PostDetailState(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,sentCount: null == sentCount ? _self.sentCount : sentCount // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}

// dart format on
