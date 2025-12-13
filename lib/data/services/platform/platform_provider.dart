import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_provider.g.dart';

@riverpod
bool mobilePlatform(Ref ref) =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

@riverpod
bool supportMaps(Ref ref) => kIsWeb || Platform.isAndroid || Platform.isIOS;

@riverpod
bool webPlatform(Ref ref) => kIsWeb;
