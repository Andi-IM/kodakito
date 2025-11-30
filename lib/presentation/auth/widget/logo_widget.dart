import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double maxWidth;
  const LogoWidget({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Image.asset(
              brightness == Brightness.light ? 'assets/logo_light.png' : 'assets/logo_dark.png',
              width: constraints.maxWidth,
            ),
          );
        }
      ),
    );
  }
}
