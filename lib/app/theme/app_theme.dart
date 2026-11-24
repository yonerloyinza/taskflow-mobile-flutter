import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => FlexThemeData.light(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 1,
    appBarElevation: 0,
    useMaterial3: true,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );

  static ThemeData get dark => FlexThemeData.dark(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 5,
    appBarElevation: 0,
    useMaterial3: true,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
}
