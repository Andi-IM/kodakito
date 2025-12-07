import 'package:flutter/material.dart';

class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = false,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    required this.builder,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
    context: context,
    settings: this,
    anchorPoint: anchorPoint,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    themes: themes,
    builder: builder,
  );
}
