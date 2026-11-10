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

  Iterable<File> under(String folder) =>
      sources.where((file) => file.path.startsWith('lib/$folder/'));

  test('the domain is plain Dart: no Flutter, Riverpod, data or '
      'infrastructure', () {
    final domain = under('domain');
    expect(domain, isNotEmpty);
    for (final forbidden in [
      "'package:flutter/",
      "'package:material_ui/",
      "'package:riverpod",
      "'package:flutter_riverpod/",
      'connect_hub_riverpod/data/',
      'connect_hub_riverpod/core/network/',
      'connect_hub_riverpod/core/database/',
      'connect_hub_riverpod/di/',
    ]) {
      expect(
        filesContaining(forbidden, among: domain),
        isEmpty,
        reason: forbidden,
      );
    }
  });

  test('only core/network/ knows the fake server is there', () {
    final outside = sources.where(
      (file) => !file.path.startsWith('lib/core/network/'),
    );
    expect(
      filesContaining('core/network/fake_server/', among: outside),
      isEmpty,
    );
    expect(filesContaining('core/network/api/fake_', among: outside), isEmpty);
  });

  test('widgets never reach the data layer: features and the design system '
      'go through providers', () {
    final ui = [...under('features'), ...under('core/design_system')];
    for (final forbidden in [
      'connect_hub_riverpod/data/',
      'connect_hub_riverpod/core/network/',
      'connect_hub_riverpod/core/database/',
    ]) {
      expect(filesContaining(forbidden, among: ui), isEmpty, reason: forbidden);
    }
  });

  test('drift files never import material_ui or the JSON packages (their '
      'names clash, conventions §11.1)', () {
    final database = under('core/database');
    expect(database, isNotEmpty);
    expect(filesContaining("'package:material_ui/", among: database), isEmpty);
    expect(
      filesContaining("'package:json_annotation/", among: database),
      isEmpty,
    );
  });

  test('one ProviderScope, in main.dart; no container outside it', () {
    expect(filesContaining('ProviderScope('), ['lib/main.dart']);
    expect(filesContaining('ProviderContainer('), isEmpty);
  });
}
