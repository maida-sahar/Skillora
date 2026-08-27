import 'package:flutter/material.dart';

class AppDecorations {
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(borderRadiusMedium));

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(13),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
