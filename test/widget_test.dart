import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_meal_planner/main.dart';
import 'package:ai_meal_planner/core/localization/locale_controller.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';

void main() {
  setUp(() {
    // Make sure the GetX controllers are registered before each test
    if (!Get.isRegistered<LocaleController>()) {
      Get.put(LocaleController());
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify that MyApp exists in the widget tree
    expect(find.byType(MyApp), findsOneWidget);
  });

  // If you still want a counter test, you need to isolate a counter widget
  // Instead of testing MyApp directly, test only the widget containing the counter.
}
