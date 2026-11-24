import 'package:flutter/widgets.dart';

class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet &&
      MediaQuery.sizeOf(context).width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static double contentMaxWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 840;
}
