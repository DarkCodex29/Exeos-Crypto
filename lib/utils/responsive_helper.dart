import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 4 : 3;
    } else if (isTablet(context)) {
      return 4;
    } else {
      return 3;
    }
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final padding = getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
    return EdgeInsets.all(padding);
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final multiplier = getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return baseFontSize * multiplier;
  }
  
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth - 32;
    } else if (isTablet(context)) {
      return screenWidth * 0.8;
    } else {
      return 600;
    }
  }
  
  static int getCryptoListColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveHelper.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}