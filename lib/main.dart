import 'package:ai_meal_planner/core/theme/app_theme.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';
import 'package:ai_meal_planner/routes/app_pages.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() {
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(393, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            initialRoute: AppRoutes.bottomNav,
            getPages: AppPages.routes,
          ),
        );
      },
    );
  }
}
