import 'dart:convert';

import 'package:connect_hub_riverpod/core/common/app_exception.dart';
import 'package:connect_hub_riverpod/core/network/asset_json_loader.dart';
import 'package:connect_hub_riverpod/core/network/fake_server/seed_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SeedLoader loaderFor(Map<String, String> files) =>
      SeedLoader(AssetJsonLoader(_FakeBundle(files)));

  test('malformed JSON surfaces as DataFormatException', () {
    final loader = loaderFor({SeedLoader.postsPath: '[{"id": '});

    expect(loader.loadPosts(), throwsA(isA<DataFormatException>()));
  });

  test('JSON of the wrong shape surfaces as DataFormatException', () {
    final loader = loaderFor({
      SeedLoader.postsPath: '[{"id": "p1"}]',
      SeedLoader.authUserPath: '["not", "an", "object"]',
    });

    expect(loader.loadPosts(), throwsA(isA<DataFormatException>()));
    expect(loader.loadAuthUser(), throwsA(isA<DataFormatException>()));
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    final bytes = utf8.encode(_files[key]!);
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
