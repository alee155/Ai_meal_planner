import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Meal Planner'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @aiDietPlanner.
  ///
  /// In en, this message translates to:
  /// **'AI Diet Planner'**
  String get aiDietPlanner;

  /// No description provided for @eatSmarterFeelStronger.
  ///
  /// In en, this message translates to:
  /// **'Eat smarter.\nFeel stronger.'**
  String get eatSmarterFeelStronger;

  /// No description provided for @splashHeadline.
  ///
  /// In en, this message translates to:
  /// **'Smarter meal planning starts here.'**
  String get splashHeadline;

  /// No description provided for @splashDescription.
  ///
  /// In en, this message translates to:
  /// **'Setting up a clean nutrition space around your goals, habits, and daily routine.'**
  String get splashDescription;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your personalized meal planner'**
  String get splashLoading;

  /// No description provided for @loginHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to unlock meal plans, daily nutrition guidance, and progress tracking built around your goals.'**
  String get loginHeroDescription;

  /// No description provided for @continueGuestMode.
  ///
  /// In en, this message translates to:
  /// **'Continue in guest mode'**
  String get continueGuestMode;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginRoutineDescription.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue building your healthy routine.'**
  String get loginRoutineDescription;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmailHint;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPasswordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @buildHealthyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Build your\nhealthy routine.'**
  String get buildHealthyRoutine;

  /// No description provided for @signupHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save meal plans, personalize nutrition goals, and keep your progress in one place.'**
  String get signupHeroDescription;

  /// No description provided for @signupDescription.
  ///
  /// In en, this message translates to:
  /// **'Start with a few details and let the app tailor your nutrition journey.'**
  String get signupDescription;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @enterFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameHint;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPasswordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @secureVerification.
  ///
  /// In en, this message translates to:
  /// **'Secure Verification'**
  String get secureVerification;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your\nOTP code.'**
  String get enterOtpCode;

  /// No description provided for @otpIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the verification code we just sent to confirm access to your account.'**
  String get otpIntroDescription;

  /// No description provided for @verificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'4-digit verification code'**
  String get verificationCodeTitle;

  /// No description provided for @otpPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code below. You can also paste it into the first box.'**
  String get otpPasteHint;

  /// No description provided for @otpReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Code looks good. You can verify now.'**
  String get otpReadyStatus;

  /// No description provided for @otpPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Code expires soon. Enter all 4 digits to continue.'**
  String get otpPendingStatus;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @didntReceiveIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it?'**
  String get didntReceiveIt;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @enterCompleteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter complete code'**
  String get enterCompleteCodeTitle;

  /// No description provided for @enterCompleteCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 4-digit verification code.'**
  String get enterCompleteCodeMessage;

  /// No description provided for @codeVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Code verified'**
  String get codeVerifiedTitle;

  /// No description provided for @codeVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'OTP {code} verified in this demo screen.'**
  String codeVerifiedMessage(String code);

  /// No description provided for @codeResentTitle.
  ///
  /// In en, this message translates to:
  /// **'Code resent'**
  String get codeResentTitle;

  /// No description provided for @codeResentMessage.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent to {destination}.'**
  String codeResentMessage(String destination);

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to'**
  String get otpSentTo;

  /// No description provided for @codeSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Code sent successfully'**
  String get codeSentSuccessfully;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent your verification code to:'**
  String get verificationCodeSentTo;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @consumedToday.
  ///
  /// In en, this message translates to:
  /// **'Consumed today'**
  String get consumedToday;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @calorieSplineChart.
  ///
  /// In en, this message translates to:
  /// **'Calorie Spline Chart'**
  String get calorieSplineChart;

  /// No description provided for @calorieColumnChart.
  ///
  /// In en, this message translates to:
  /// **'Calorie Column Chart'**
  String get calorieColumnChart;

  /// No description provided for @weeklyTotalCalorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly total calorie trend'**
  String get weeklyTotalCalorieTrend;

  /// No description provided for @weeklyCalorieComparisonByDay.
  ///
  /// In en, this message translates to:
  /// **'Weekly calorie comparison by day'**
  String get weeklyCalorieComparisonByDay;

  /// No description provided for @spline.
  ///
  /// In en, this message translates to:
  /// **'Spline'**
  String get spline;

  /// No description provided for @bars.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get bars;

  /// No description provided for @lowestKcal.
  ///
  /// In en, this message translates to:
  /// **'Lowest: {value} kcal'**
  String lowestKcal(int value);

  /// No description provided for @peakKcal.
  ///
  /// In en, this message translates to:
  /// **'Peak: {value} kcal'**
  String peakKcal(int value);

  /// No description provided for @openDietPlan.
  ///
  /// In en, this message translates to:
  /// **'Open Diet Plan'**
  String get openDietPlan;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @dietPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan'**
  String get dietPlanTitle;

  /// No description provided for @dietPlanHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Personalized meals aligned with your calorie and macro goals.'**
  String get dietPlanHeaderDescription;

  /// No description provided for @todayDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Today • {month} {day}'**
  String todayDateLabel(String month, int day);

  /// No description provided for @dailyCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie target'**
  String get dailyCalorieTarget;

  /// No description provided for @aiBalanced.
  ///
  /// In en, this message translates to:
  /// **'AI Balanced'**
  String get aiBalanced;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todaysProgress;

  /// No description provided for @completedMealsCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} meals completed'**
  String completedMealsCount(int completed, int total);

  /// No description provided for @consumedCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'{consumed} kcal consumed'**
  String consumedCaloriesLabel(int consumed);

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @breakfastSummary.
  ///
  /// In en, this message translates to:
  /// **'High protein, rich in fiber, and balanced for a steady morning energy curve.'**
  String get breakfastSummary;

  /// No description provided for @lunchSummary.
  ///
  /// In en, this message translates to:
  /// **'Complete protein and complex carbs to keep energy stable through the afternoon.'**
  String get lunchSummary;

  /// No description provided for @snackSummary.
  ///
  /// In en, this message translates to:
  /// **'A light recovery snack that supports satiety without pushing calories too high.'**
  String get snackSummary;

  /// No description provided for @dinnerSummary.
  ///
  /// In en, this message translates to:
  /// **'Omega-3 fats and micronutrients to round out the day without a heavy finish.'**
  String get dinnerSummary;

  /// No description provided for @mealStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get mealStatusPending;

  /// No description provided for @mealStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get mealStatusCompleted;

  /// No description provided for @mealStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get mealStatusSkipped;

  /// No description provided for @markMealDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markMealDone;

  /// No description provided for @skipMeal.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipMeal;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @completedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed at {time}'**
  String completedAtLabel(String time);

  /// No description provided for @viewNutritionDetails.
  ///
  /// In en, this message translates to:
  /// **'View nutrition details'**
  String get viewNutritionDetails;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStep;

  /// No description provided for @dietPlanNextStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn this plan into a shopping checklist or ask the AI to refresh your meals.'**
  String get dietPlanNextStepDescription;

  /// No description provided for @generateShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Generate Shopping List'**
  String get generateShoppingList;

  /// No description provided for @refreshPlan.
  ///
  /// In en, this message translates to:
  /// **'Refresh Plan'**
  String get refreshPlan;

  /// No description provided for @mealDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'{mealTitle} details'**
  String mealDetailsTitle(String mealTitle);

  /// No description provided for @mealDetailsMessage.
  ///
  /// In en, this message translates to:
  /// **'Nutrition breakdown, ingredients, and substitutions can be connected here.'**
  String get mealDetailsMessage;

  /// No description provided for @mealCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{mealTitle} marked as completed.'**
  String mealCompletedMessage(String mealTitle);

  /// No description provided for @mealSkippedMessage.
  ///
  /// In en, this message translates to:
  /// **'{mealTitle} marked as skipped.'**
  String mealSkippedMessage(String mealTitle);

  /// No description provided for @shoppingListReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list ready'**
  String get shoppingListReadyTitle;

  /// No description provided for @shoppingListReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect this action to your shopping-list flow next.'**
  String get shoppingListReadyMessage;

  /// No description provided for @planRefreshRequestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan refresh requested'**
  String get planRefreshRequestedTitle;

  /// No description provided for @planRefreshRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Swap this placeholder with your AI meal-generation flow.'**
  String get planRefreshRequestedMessage;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsUnreadSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} unread updates from your AI meal planner'**
  String notificationsUnreadSummary(int count);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @stayOnTopPlan.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your plan'**
  String get stayOnTopPlan;

  /// No description provided for @notificationsIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders, calorie insights, hydration alerts, and AI updates all show here.'**
  String get notificationsIntroDescription;

  /// No description provided for @breakfastReminder.
  ///
  /// In en, this message translates to:
  /// **'Breakfast reminder'**
  String get breakfastReminder;

  /// No description provided for @breakfastReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Your high-protein breakfast window starts in 20 minutes.'**
  String get breakfastReminderMessage;

  /// No description provided for @caloriesOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Calories on track'**
  String get caloriesOnTrack;

  /// No description provided for @caloriesOnTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'You stayed within your calorie target for 3 days in a row.'**
  String get caloriesOnTrackMessage;

  /// No description provided for @hydrationReminder.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminder'**
  String get hydrationReminder;

  /// No description provided for @hydrationReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Drink one more glass of water to stay on pace for today.'**
  String get hydrationReminderMessage;

  /// No description provided for @aiPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'AI plan updated'**
  String get aiPlanUpdated;

  /// No description provided for @aiPlanUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your lunch recommendation was adjusted for better protein balance.'**
  String get aiPlanUpdatedMessage;

  /// No description provided for @weeklyInsightReady.
  ///
  /// In en, this message translates to:
  /// **'Weekly insight ready'**
  String get weeklyInsightReady;

  /// No description provided for @weeklyInsightReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your weekly nutrition trend is available to review.'**
  String get weeklyInsightReadyMessage;

  /// No description provided for @subscriptionRenewed.
  ///
  /// In en, this message translates to:
  /// **'Subscription renewed'**
  String get subscriptionRenewed;

  /// No description provided for @subscriptionRenewedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your AI Diet Planner premium plan is active for another month.'**
  String get subscriptionRenewedMessage;

  /// No description provided for @todayTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Today • {time}'**
  String todayTimeLabel(String time);

  /// No description provided for @yesterdayTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday • {time}'**
  String yesterdayTimeLabel(String time);

  /// No description provided for @monthDayTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'{monthDay} • {time}'**
  String monthDayTimeLabel(String monthDay, String time);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your account, privacy, and subscription'**
  String get settingsDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch the app language between English and Urdu'**
  String get languageSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @languageChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChangedTitle;

  /// No description provided for @languageChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'The app language has been changed.'**
  String get languageChangedMessage;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @subscriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get subscriptionSection;

  /// No description provided for @availableSubscriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Available Subscription'**
  String get availableSubscriptionSection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @privacySecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecuritySection;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// No description provided for @personalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email, and profile preferences'**
  String get personalDetailsSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password securely'**
  String get changePasswordSubtitle;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get connectedDevices;

  /// No description provided for @connectedDevicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage sessions across your devices'**
  String get connectedDevicesSubtitle;

  /// No description provided for @activeDevicesBadge.
  ///
  /// In en, this message translates to:
  /// **'2 active'**
  String get activeDevicesBadge;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders'**
  String get mealReminders;

  /// No description provided for @mealRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Breakfast, lunch, dinner, and snack alerts'**
  String get mealRemindersSubtitle;

  /// No description provided for @hydrationReminders.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminders'**
  String get hydrationReminders;

  /// No description provided for @hydrationRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep daily water goals on track'**
  String get hydrationRemindersSubtitle;

  /// No description provided for @weeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'Weekly insights'**
  String get weeklyInsights;

  /// No description provided for @weeklyInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get progress reports every Sunday'**
  String get weeklyInsightsSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme for the app'**
  String get darkModeSubtitle;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock'**
  String get biometricLock;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID or fingerprint to open app'**
  String get biometricLockSubtitle;

  /// No description provided for @marketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing emails'**
  String get marketingEmails;

  /// No description provided for @marketingEmailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Product updates, offers, and app news'**
  String get marketingEmailsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your nutrition data is used and protected'**
  String get privacyPolicySubtitle;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs, troubleshooting, and guidance'**
  String get helpCenterSubtitle;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach the team for billing or account help'**
  String get contactSupportSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @appVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI Diet Planner 1.0.0'**
  String get appVersionSubtitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @premiumPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock expert guidance and advanced AI planning'**
  String get premiumPlanSubtitle;

  /// No description provided for @viewPerks.
  ///
  /// In en, this message translates to:
  /// **'View perks'**
  String get viewPerks;

  /// No description provided for @viewPlan.
  ///
  /// In en, this message translates to:
  /// **'View plan'**
  String get viewPlan;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @profileSubscriptionAiAccess.
  ///
  /// In en, this message translates to:
  /// **'AI Access'**
  String get profileSubscriptionAiAccess;

  /// No description provided for @profileSubscriptionDietitian.
  ///
  /// In en, this message translates to:
  /// **'Dietitian'**
  String get profileSubscriptionDietitian;

  /// No description provided for @profileSubscriptionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSubscriptionSupport;

  /// No description provided for @subscriptionUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get subscriptionUnlimited;

  /// No description provided for @subscriptionIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get subscriptionIncluded;

  /// No description provided for @subscriptionPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get subscriptionPriority;

  /// No description provided for @availableSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Subscription'**
  String get availableSubscriptionTitle;

  /// No description provided for @availableSubscriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium for expert support, stronger AI planning, and deeper health insights.'**
  String get availableSubscriptionDescription;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM ACTIVE'**
  String get premiumActive;

  /// No description provided for @monthlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get monthlyBilling;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock expert guidance, deeper AI personalization, and long-term planning tools built for measurable progress.'**
  String get premiumDescription;

  /// No description provided for @highlightUnlimitedAiChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI chat'**
  String get highlightUnlimitedAiChat;

  /// No description provided for @highlightDietitianConsults.
  ///
  /// In en, this message translates to:
  /// **'Dietitian consults'**
  String get highlightDietitianConsults;

  /// No description provided for @highlightPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get highlightPrioritySupport;

  /// No description provided for @activatePremium.
  ///
  /// In en, this message translates to:
  /// **'Activate Premium'**
  String get activatePremium;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Premium benefits'**
  String get premiumBenefits;

  /// No description provided for @premiumBenefitsDescription.
  ///
  /// In en, this message translates to:
  /// **'These features are available only to Premium users.'**
  String get premiumBenefitsDescription;

  /// No description provided for @professionalDietitianConsultations.
  ///
  /// In en, this message translates to:
  /// **'Professional Dietitian Consultations'**
  String get professionalDietitianConsultations;

  /// No description provided for @professionalDietitianConsultationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Direct access to certified nutrition experts.'**
  String get professionalDietitianConsultationsDescription;

  /// No description provided for @advancedAiOptimization.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI Optimization'**
  String get advancedAiOptimization;

  /// No description provided for @advancedAiOptimizationDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-generated meal plans with enhanced personalization and efficiency for faster results.'**
  String get advancedAiOptimizationDescription;

  /// No description provided for @personalizedLongTermPlans.
  ///
  /// In en, this message translates to:
  /// **'Personalized Long-Term Plans'**
  String get personalizedLongTermPlans;

  /// No description provided for @personalizedLongTermPlansDescription.
  ///
  /// In en, this message translates to:
  /// **'Customized weekly or monthly diet plans tailored to user health goals.'**
  String get personalizedLongTermPlansDescription;

  /// No description provided for @unlimitedAiChatbotAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Chatbot Access'**
  String get unlimitedAiChatbotAccess;

  /// No description provided for @unlimitedAiChatbotAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Full access to AI guidance without the limitations guest or free users have.'**
  String get unlimitedAiChatbotAccessDescription;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get prioritySupport;

  /// No description provided for @prioritySupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Faster responses and support for app-related issues.'**
  String get prioritySupportDescription;

  /// No description provided for @enhancedAnalyticsInsights.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Analytics & Insights'**
  String get enhancedAnalyticsInsights;

  /// No description provided for @enhancedAnalyticsInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Advanced progress tracking, trend analysis, and richer nutrition insights.'**
  String get enhancedAnalyticsInsightsDescription;

  /// No description provided for @managePlan.
  ///
  /// In en, this message translates to:
  /// **'Manage plan'**
  String get managePlan;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @viewBenefits.
  ///
  /// In en, this message translates to:
  /// **'View benefits'**
  String get viewBenefits;

  /// No description provided for @nextBillingDate.
  ///
  /// In en, this message translates to:
  /// **'Next billing date: {date}'**
  String nextBillingDate(String date);

  /// No description provided for @premiumAlreadyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium already active'**
  String get premiumAlreadyActiveTitle;

  /// No description provided for @premiumAlreadyActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your premium plan is already enabled on this account.'**
  String get premiumAlreadyActiveMessage;

  /// No description provided for @premiumActivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium activated'**
  String get premiumActivatedTitle;

  /// No description provided for @premiumActivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your premium subscription is now active across the app.'**
  String get premiumActivatedMessage;

  /// No description provided for @manageSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscriptionTitle;

  /// No description provided for @manageSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Next billing date: {date}'**
  String manageSubscriptionMessage(String date);

  /// No description provided for @setUpYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get setUpYourProfile;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete setup'**
  String get completeSetup;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @profileUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedTitle;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your nutrition preferences are saved.'**
  String get profileUpdatedMessage;

  /// No description provided for @finishProfileSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile so AI meals match your body, goals, and food restrictions.'**
  String get finishProfileSetupMessage;

  /// No description provided for @profileSetupStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String profileSetupStepLabel(int current, int total);

  /// No description provided for @setupSkippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup skipped'**
  String get setupSkippedTitle;

  /// No description provided for @setupSkippedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can complete your profile later from the Profile tab.'**
  String get setupSkippedMessage;

  /// No description provided for @completeRequiredFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete required details'**
  String get completeRequiredFieldsTitle;

  /// No description provided for @completeRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your age, weight, height, activity level, and goal before continuing.'**
  String get completeRequiredFieldsMessage;

  /// No description provided for @completeYourProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfileTitle;

  /// No description provided for @completeYourProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your body stats, goals, and food restrictions so AI meal planning is safer and more accurate.'**
  String get completeYourProfileMessage;

  /// No description provided for @resumeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete now'**
  String get resumeSetup;

  /// No description provided for @profileIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your nutrition plan'**
  String get profileIntroDescription;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @bmiAutoCalculated.
  ///
  /// In en, this message translates to:
  /// **'BMI (Auto-calculated)'**
  String get bmiAutoCalculated;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get notEnoughData;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @selectActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Select activity level'**
  String get selectActivityLevel;

  /// No description provided for @lightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get lightlyActive;

  /// No description provided for @moderatelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get moderatelyActive;

  /// No description provided for @veryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// No description provided for @yourFitnessGoals.
  ///
  /// In en, this message translates to:
  /// **'Your Fitness Goals'**
  String get yourFitnessGoals;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// No description provided for @gainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get gainMuscle;

  /// No description provided for @foodPreferences.
  ///
  /// In en, this message translates to:
  /// **'Food Preferences'**
  String get foodPreferences;

  /// No description provided for @foodPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These selections help AI avoid unsafe ingredients and tailor your meals.'**
  String get foodPreferencesSubtitle;

  /// No description provided for @dietPreference.
  ///
  /// In en, this message translates to:
  /// **'Diet Preference'**
  String get dietPreference;

  /// No description provided for @selectDietPreference.
  ///
  /// In en, this message translates to:
  /// **'Select diet preference'**
  String get selectDietPreference;

  /// No description provided for @balancedDiet.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balancedDiet;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @highProteinDiet.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get highProteinDiet;

  /// No description provided for @allergiesAndAvoidances.
  ///
  /// In en, this message translates to:
  /// **'Allergies & Avoidances'**
  String get allergiesAndAvoidances;

  /// No description provided for @allergiesSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose anything the AI must never include.'**
  String get allergiesSelectionHint;

  /// No description provided for @peanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get peanuts;

  /// No description provided for @treeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get treeNuts;

  /// No description provided for @dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// No description provided for @shellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get shellfish;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get soy;

  /// No description provided for @wheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get wheat;

  /// No description provided for @sesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get sesame;

  /// No description provided for @dislikedFoods.
  ///
  /// In en, this message translates to:
  /// **'Disliked Foods'**
  String get dislikedFoods;

  /// No description provided for @dislikedFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: mushrooms, olives, liver'**
  String get dislikedFoodsHint;

  /// No description provided for @allergySafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Selected allergens should be excluded from AI meal suggestions.'**
  String get allergySafetyNote;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loggedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOutTitle;

  /// No description provided for @loggedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'See you again soon.'**
  String get loggedOutMessage;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackTitle;

  /// No description provided for @mealPlannerReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your meal planner is ready.'**
  String get mealPlannerReadyMessage;

  /// No description provided for @googleSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in'**
  String get googleSignInTitle;

  /// No description provided for @googleSignInMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect the real Google auth flow next.'**
  String get googleSignInMessage;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreatedTitle;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your AI diet planner journey.'**
  String get accountCreatedMessage;

  /// No description provided for @googleSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Google sign-up'**
  String get googleSignUpTitle;

  /// No description provided for @googleSignUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect the real Google onboarding flow next.'**
  String get googleSignUpMessage;

  /// No description provided for @helpCenterMessage.
  ///
  /// In en, this message translates to:
  /// **'This area is ready for FAQ content or customer support links.'**
  String get helpCenterMessage;

  /// No description provided for @contactSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Email: support@aimealplanner.app'**
  String get contactSupportMessage;

  /// No description provided for @privacyPolicyMessage.
  ///
  /// In en, this message translates to:
  /// **'This can later open a webview or markdown page with your policy.'**
  String get privacyPolicyMessage;

  /// No description provided for @personalDetailsMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect this tile to your profile edit flow when you are ready.'**
  String get personalDetailsMessage;

  /// No description provided for @connectedDevicesMessage.
  ///
  /// In en, this message translates to:
  /// **'Phone and tablet are currently signed in to this account.'**
  String get connectedDevicesMessage;

  /// No description provided for @premiumBenefitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Dietitian consultations, advanced AI optimization, long-term plans, unlimited chatbot access, priority support, and enhanced insights are included.'**
  String get premiumBenefitsMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
