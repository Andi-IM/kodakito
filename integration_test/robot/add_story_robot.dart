import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AddStoryRobot {
  final WidgetTester tester;

  AddStoryRobot(this.tester);

  final addStoryButtonFinder = ValueKey('addStoryButton');

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump();
  }

  Future<void> tapAddStoryButton() async {
    final buttonFinder = find.byIcon(Icons.add);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> grantPermission() async {
    if (Platform.isWindows) {
      // Assuming the test is running on a connected Android device via ADB from Windows
      final permissions = [
        'android.permission.CAMERA',
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
      ];

      for (final permission in permissions) {
        await Process.run('adb', [
          'shell',
          'pm',
          'grant',
          'com.example.kodakito',
          permission,
        ]);
      }
    }
  }

  Future<void> revokePermission() async {
    if (Platform.isWindows) {
      final permissions = [
        'android.permission.CAMERA',
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
      ];

      for (final permission in permissions) {
        await Process.run('adb', [
          'shell',
          'pm',
          'revoke',
          'com.example.kodakito',
          permission,
        ]);
      }
    }
  }
}
