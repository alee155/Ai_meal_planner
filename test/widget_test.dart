import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_meal_planner/main.dart';
import 'package:ai_meal_planner/core/localization/locale_controller.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';

void main() {
  setUp(() {
    // Ensure clean state before each test
    Get.reset();

    // Register required controllers
    Get.put(LocaleController());
    Get.put(ThemeController());
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // ✅ Important: allow UI + animations to initialize
    await tester.pump(const Duration(milliseconds: 200));

    // ✅ Verify app loaded
    expect(find.byType(MyApp), findsOneWidget);
  });
}
