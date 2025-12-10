import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/init.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dicoding_story/app/app_env.dart';

void main() async {
  await initApp(AppEnvironment.production);
  runApp(ProviderScope(observers: [Observer()], child: MyApp()));
}
