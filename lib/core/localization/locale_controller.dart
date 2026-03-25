import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  final Rx<Locale> locale = _initialLocale().obs;

  static LocaleController ensureRegistered() {
    if (Get.isRegistered<LocaleController>()) {
      return Get.find<LocaleController>();
    }

    return Get.put(LocaleController(), permanent: true);
  }

  static Locale _initialLocale() {
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale?.languageCode == 'ur') {
      return const Locale('ur');
    }

    return const Locale('en');
  }

  bool get isUrdu => locale.value.languageCode == 'ur';

  void updateLanguage(Locale nextLocale) {
    locale.value = nextLocale;
    Get.updateLocale(nextLocale);
  }
}
