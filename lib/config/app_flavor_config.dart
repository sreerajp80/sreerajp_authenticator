import '../utils/constants.dart';

enum AppFlavor { dev, prod }

class AppFlavorConfig {
  AppFlavorConfig._(this.flavor);

  static final AppFlavorConfig instance = AppFlavorConfig.fromFlavorValue(
    const String.fromEnvironment('FLUTTER_APP_FLAVOR', defaultValue: 'prod'),
  );

  final AppFlavor flavor;

  static AppFlavorConfig fromFlavorValue(String value) {
    return AppFlavorConfig._(_parseFlavor(value));
  }

  static AppFlavor _parseFlavor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;

  bool get isProd => flavor == AppFlavor.prod;

  String get appName {
    if (isDev) {
      return AppConstants.appNameDev;
    }
    return AppConstants.appNameProd;
  }

  String get environmentName {
    if (isDev) {
      return AppConstants.environmentNameDev;
    }
    return AppConstants.environmentNameProd;
  }

  String get bannerLabel {
    if (isDev) {
      return AppConstants.bannerLabelDev;
    }
    return AppConstants.bannerLabelProd;
  }

  bool get showEnvironmentBanner => isDev;

  bool get enableVerboseLogging => isDev;
}
