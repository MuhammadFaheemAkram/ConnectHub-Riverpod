import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Rules the analyzer can't express, checked over the source tree.
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .toList();

  List<String> filesContaining(Pattern pattern, {Iterable<File>? among}) => [
    for (final file in among ?? sources)
      if (file.readAsStringSync().contains(pattern)) file.path,
  ];

  test('finds the sources', () {
    expect(sources, isNotEmpty);
  });

  test('Material comes from material_ui, never the in-SDK library', () {
    expect(filesContaining("'package:flutter/material.dart'"), isEmpty);
  });

  test("no legacy providers: Riverpod 3 keeps them in 'legacy.dart'", () {
    expect(filesContaining('flutter_riverpod/legacy.dart'), isEmpty);
    expect(filesContaining('riverpod/legacy.dart'), isEmpty);
    for (final legacy in [
      'StateProvider',
      'StateNotifierProvider',
      'ChangeNotifierProvider',
    ]) {
      expect(filesContaining(RegExp('\\b$legacy\\b')), isEmpty, reason: legacy);
    }
  });

  test('providers are the DI: no service locator, no Bloc', () {
    for (final package in ['get_it', 'injectable', 'flutter_bloc', 'bloc']) {
      expect(filesContaining("'package:$package/"), isEmpty, reason: package);
    }
  });

  test('one ProviderScope, in main.dart; no container outside it', () {
    expect(filesContaining('ProviderScope('), ['lib/main.dart']);
    expect(filesContaining('ProviderContainer('), isEmpty);
  });
}
