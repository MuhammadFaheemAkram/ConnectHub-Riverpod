// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {

 User get user;/// Their posts, newest first.
 List<Post> get posts;/// A one-off SnackBar, consumed by `messageShown()`.
 String? get message;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.user, _this.user) || other.user == _this.user)&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as ProfileState;
  return Object.hash(runtimeType,_this.user,const DeepCollectionEquality().hash(_this.posts),_this.message);
}

@override
String toString() {
  final _this = this as ProfileState;
  return 'ProfileState(user: ${_this.user}, posts: ${_this.posts}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 User user, List<Post> posts, String? message
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? posts = null,Object? message = freezed,}) {
  return _then(ProfileState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  List<Post> posts,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.user,_that.posts,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  List<Post> posts,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that.user,_that.posts,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  List<Post> posts,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.user,_that.posts,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileState implements ProfileState {
  const _ProfileState({required this.user,  List<Post> posts = const <Post>[], this.message}): _posts = posts;
  

@override final  User user;
/// Their posts, newest first.
 final  List<Post> _posts;
/// Their posts, newest first.
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// A one-off SnackBar, consumed by `messageShown()`.
@override final  String? message;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,const DeepCollectionEquality().hash(_posts),message);
}

@override
String toString() {
    return 'ProfileState(user: $user, posts: $posts, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 User user, List<Post> posts, String? message
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? posts = null,Object? message = freezed,}) {
  return _then(_ProfileState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc
mixin _$SavedPostsState {

/// The most recently saved first.
 List<Post> get posts;/// A one-off SnackBar.
 String? get message;/// The post just unsaved: the SnackBar offers Undo for it.
 Post? get undoable;
/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPostsStateCopyWith<SavedPostsState> get copyWith => _$SavedPostsStateCopyWithImpl<SavedPostsState>(this as SavedPostsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SavedPostsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPostsState&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.undoable, _this.undoable) || other.undoable == _this.undoable));
}


@override
int get hashCode {
  final _this = this as SavedPostsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.posts),_this.message,_this.undoable);
}

@override
String toString() {
  final _this = this as SavedPostsState;
  return 'SavedPostsState(posts: ${_this.posts}, message: ${_this.message}, undoable: ${_this.undoable})';
}


}

/// @nodoc
abstract mixin class $SavedPostsStateCopyWith<$Res>  {
  factory $SavedPostsStateCopyWith(SavedPostsState value, $Res Function(SavedPostsState) _then) = _$SavedPostsStateCopyWithImpl;
@useResult
$Res call({
 List<Post> posts, String? message, Post? undoable
});


$PostCopyWith<$Res>? get undoable;

}
/// @nodoc
class _$SavedPostsStateCopyWithImpl<$Res>
    implements $SavedPostsStateCopyWith<$Res> {
  _$SavedPostsStateCopyWithImpl(this._self, this._then);

  final SavedPostsState _self;
  final $Res Function(SavedPostsState) _then;

/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? message = freezed,Object? undoable = freezed,}) {
  return _then(SavedPostsState(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,undoable: freezed == undoable ? _self.undoable : undoable // ignore: cast_nullable_to_non_nullable
as Post?,
  ));
}
/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get undoable {
    if (_self.undoable == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.undoable!, (value) {
    return _then(_self.copyWith(undoable: value));
  });
}
}


/// Adds pattern-matching-related methods to [SavedPostsState].
extension SavedPostsStatePatterns on SavedPostsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPostsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPostsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPostsState value)  $default,){
final _that = this;
switch (_that) {
case _SavedPostsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPostsState value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPostsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Post> posts,  String? message,  Post? undoable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPostsState() when $default != null:
return $default(_that.posts,_that.message,_that.undoable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Post> posts,  String? message,  Post? undoable)  $default,) {final _that = this;
switch (_that) {
case _SavedPostsState():
return $default(_that.posts,_that.message,_that.undoable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Post> posts,  String? message,  Post? undoable)?  $default,) {final _that = this;
switch (_that) {
case _SavedPostsState() when $default != null:
return $default(_that.posts,_that.message,_that.undoable);case _:
  return null;

}
}

}

/// @nodoc


class _SavedPostsState implements SavedPostsState {
  const _SavedPostsState({ List<Post> posts = const <Post>[], this.message, this.undoable}): _posts = posts;
  

/// The most recently saved first.
 final  List<Post> _posts;
/// The most recently saved first.
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// A one-off SnackBar.
@override final  String? message;
/// The post just unsaved: the SnackBar offers Undo for it.
@override final  Post? undoable;

/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPostsStateCopyWith<_SavedPostsState> get copyWith => __$SavedPostsStateCopyWithImpl<_SavedPostsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPostsState&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.message, message) || other.message == message)&&(identical(other.undoable, undoable) || other.undoable == undoable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),message,undoable);
}

@override
String toString() {
    return 'SavedPostsState(posts: $posts, message: $message, undoable: $undoable)';
}


}

/// @nodoc
abstract mixin class _$SavedPostsStateCopyWith<$Res> implements $SavedPostsStateCopyWith<$Res> {
  factory _$SavedPostsStateCopyWith(_SavedPostsState value, $Res Function(_SavedPostsState) _then) = __$SavedPostsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Post> posts, String? message, Post? undoable
});


@override $PostCopyWith<$Res>? get undoable;

}
/// @nodoc
class __$SavedPostsStateCopyWithImpl<$Res>
    implements _$SavedPostsStateCopyWith<$Res> {
  __$SavedPostsStateCopyWithImpl(this._self, this._then);

  final _SavedPostsState _self;
  final $Res Function(_SavedPostsState) _then;

/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? message = freezed,Object? undoable = freezed,}) {
  return _then(_SavedPostsState(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,undoable: freezed == undoable ? _self.undoable : undoable // ignore: cast_nullable_to_non_nullable
as Post?,
  ));
}

/// Create a copy of SavedPostsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get undoable {
    if (_self.undoable == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.undoable!, (value) {
    return _then(_self.copyWith(undoable: value));
  });
}
}

// dart format on
