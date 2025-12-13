import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final class Observer extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // Avoid stringifying large objects
    final valueString = newValue.toString();
    final truncatedValue = valueString.length > 200
        ? '${valueString.substring(0, 200)}...'
        : valueString;

    log(
      'Provider updated: ${context.provider.name ?? context.provider.runtimeType} -> $truncatedValue',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log(
      'Provider disposed: ${context.provider.name ?? context.provider.runtimeType}',
    );
    super.didDisposeProvider(context);
  }
}
