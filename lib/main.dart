import 'package:ai_meal_planner/core/localization/locale_controller.dart';
import 'package:ai_meal_planner/core/theme/app_theme.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';
import 'package:ai_meal_planner/features/AlarmRingScreen/ui/alarm_ring_screen.dart';
import 'package:ai_meal_planner/l10n/app_localizations.dart';
import 'package:ai_meal_planner/notification_service.dart';
import 'package:ai_meal_planner/routes/app_pages.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final launchAlarmData = await NotificationService.getLaunchAlarmData();
  LocaleController.ensureRegistered();
  await ThemeController.ensureRegistered().init();
  runApp(MyApp(initialAlarmData: launchAlarmData));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialAlarmData});

  final AlarmLaunchData? initialAlarmData;

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(393, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            locale: localeController.locale.value,
            home: initialAlarmData == null
                ? null
                : AlarmRingScreen(initialAlarmData: initialAlarmData),
            initialRoute: initialAlarmData == null
                ? AppRoutes.multicolorloader
                : null,
            getPages: AppPages.routes,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}
