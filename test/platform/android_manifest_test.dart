import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// What only a release build would show: the debug and profile manifests
// add INTERNET for development, so every debug run loads the images even
// when the main manifest forgets it (a release build then shows only the
// fallbacks). Read the file itself.
void main() {
  test('the main Android manifest asks for the network (the images)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(
      manifest,
      contains('<uses-permission android:name="android.permission.INTERNET"/>'),
    );
  });
}
