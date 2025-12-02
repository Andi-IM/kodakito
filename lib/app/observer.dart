import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class Observer extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log('''
{
  "provider": "${context.provider.name ?? context.provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log('''
{
  "provider": "${context.provider.name ?? context.provider.runtimeType}",
  "newValue": "disposed"
}''');
    super.didDisposeProvider(context);
  }
}
