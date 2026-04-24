import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLinks {
  AppLinks._();

  static final Uri privacyPolicy = Uri.parse(
    'https://aidietplanneradminpanel.dgexpense.com/privacy_policy',
  );

  static final Uri deleteAccount = Uri.parse(
    'https://aidietplanneradminpanel.dgexpense.com/delete_account',
  );

  static final Uri termsAndConditions = Uri.parse(
    'https://aidietplanneradminpanel.dgexpense.com/terms_and_conditions',
  );

  static Future<void> open(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return;
      }

      final fallbackLaunched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!fallbackLaunched) {
        AppSnackbar.error('Unable to open link', 'Please try again later.');
      }
    } catch (_) {
      AppSnackbar.error('Unable to open link', 'Please try again later.');
    }
  }
}
