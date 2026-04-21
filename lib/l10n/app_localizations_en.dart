// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Meal Planner';

  @override
  String get navHome => 'Home';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get aiDietPlanner => 'AI Diet Planner';

  @override
  String get eatSmarterFeelStronger => 'Eat smarter.\nFeel stronger.';

  @override
  String get splashHeadline => 'Smarter meal planning starts here.';

  @override
  String get splashDescription =>
      'Setting up a clean nutrition space around your goals, habits, and daily routine.';

  @override
  String get splashLoading => 'Preparing your personalized meal planner';

  @override
  String get loginHeroDescription =>
      'Sign in to unlock meal plans, daily nutrition guidance, and progress tracking built around your goals.';

  @override
  String get continueGuestMode => 'Continue in guest mode';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginRoutineDescription =>
      'Log in to continue building your healthy routine.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterEmailHint => 'Enter your email';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get buildHealthyRoutine => 'Build your\nhealthy routine.';

  @override
  String get signupHeroDescription =>
      'Create an account to save meal plans, personalize nutrition goals, and keep your progress in one place.';

  @override
  String get signupDescription =>
      'Start with a few details and let the app tailor your nutrition journey.';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get enterFullNameHint => 'Enter your full name';

  @override
  String get createPasswordHint => 'Create a password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get secureVerification => 'Secure Verification';

  @override
  String get enterOtpCode => 'Enter your\nOTP code.';

  @override
  String get otpIntroDescription =>
      'Use the verification code we just sent to confirm access to your account.';

  @override
  String get verificationCodeTitle => '6-digit verification code';

  @override
  String get otpPasteHint =>
      'Enter the code below. You can also paste it into the first box.';

  @override
  String get otpReadyStatus => 'Code looks good. You can verify now.';

  @override
  String get otpPendingStatus =>
      'Code expires soon. Enter all 6 digits to continue.';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get didntReceiveIt => 'Didn\'t receive it?';

  @override
  String get resendCode => 'Resend code';

  @override
  String get enterCompleteCodeTitle => 'Enter complete code';

  @override
  String get enterCompleteCodeMessage =>
      'Please enter the full 6-digit verification code.';

  @override
  String get codeVerifiedTitle => 'Code verified';

  @override
  String codeVerifiedMessage(String code) {
    return 'OTP $code verified in this demo screen.';
  }

  @override
  String get codeResentTitle => 'Code resent';

  @override
  String codeResentMessage(String destination) {
    return 'A new verification code has been sent to $destination.';
  }

  @override
  String get otpSentTo => 'We sent a code to';

  @override
  String get codeSentSuccessfully => 'Code sent successfully';

  @override
  String get verificationCodeSentTo => 'We sent your verification code to:';

  @override
  String get change => 'Change';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get today => 'TODAY';

  @override
  String get consumedToday => 'Consumed today';

  @override
  String get goal => 'Goal';

  @override
  String get remaining => 'Remaining';

  @override
  String get calorieSplineChart => 'Calorie Spline Chart';

  @override
  String get calorieColumnChart => 'Calorie Column Chart';

  @override
  String get weeklyTotalCalorieTrend => 'Weekly total calorie trend';

  @override
  String get weeklyCalorieComparisonByDay => 'Weekly calorie comparison by day';

  @override
  String get spline => 'Spline';

  @override
  String get bars => 'Bars';

  @override
  String lowestKcal(int value) {
    return 'Lowest: $value kcal';
  }

  @override
  String peakKcal(int value) {
    return 'Peak: $value kcal';
  }

  @override
  String get openDietPlan => 'Open Diet Plan';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get dietPlanTitle => 'Diet Plan';

  @override
  String get dietPlanHeaderDescription =>
      'Personalized meals aligned with your calorie and macro goals.';

  @override
  String todayDateLabel(String month, int day) {
    return 'Today • $month $day';
  }

  @override
  String get dailyCalorieTarget => 'Daily calorie target';

  @override
  String get aiBalanced => 'AI Balanced';

  @override
  String get todaysProgress => 'Today\'s progress';

  @override
  String completedMealsCount(int completed, int total) {
    return '$completed of $total meals completed';
  }

  @override
  String consumedCaloriesLabel(int consumed) {
    return '$consumed kcal consumed';
  }

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get snack => 'Snack';

  @override
  String get dinner => 'Dinner';

  @override
  String get breakfastSummary =>
      'High protein, rich in fiber, and balanced for a steady morning energy curve.';

  @override
  String get lunchSummary =>
      'Complete protein and complex carbs to keep energy stable through the afternoon.';

  @override
  String get snackSummary =>
      'A light recovery snack that supports satiety without pushing calories too high.';

  @override
  String get dinnerSummary =>
      'Omega-3 fats and micronutrients to round out the day without a heavy finish.';

  @override
  String get mealStatusPending => 'Planned';

  @override
  String get mealStatusCompleted => 'Completed';

  @override
  String get mealStatusSkipped => 'Skipped';

  @override
  String get markMealDone => 'Mark as done';

  @override
  String get skipMeal => 'Skip';

  @override
  String get undoAction => 'Undo';

  @override
  String completedAtLabel(String time) {
    return 'Completed at $time';
  }

  @override
  String get viewNutritionDetails => 'View nutrition details';

  @override
  String get nextStep => 'Next step';

  @override
  String get dietPlanNextStepDescription =>
      'Turn this plan into a shopping checklist or ask the AI to refresh your meals.';

  @override
  String get generateShoppingList => 'Generate Shopping List';

  @override
  String get refreshPlan => 'Refresh Plan';

  @override
  String mealDetailsTitle(String mealTitle) {
    return '$mealTitle details';
  }

  @override
  String get mealDetailsMessage =>
      'Nutrition breakdown, ingredients, and substitutions can be connected here.';

  @override
  String mealCompletedMessage(String mealTitle) {
    return '$mealTitle marked as completed.';
  }

  @override
  String mealSkippedMessage(String mealTitle) {
    return '$mealTitle marked as skipped.';
  }

  @override
  String get shoppingListReadyTitle => 'Shopping list ready';

  @override
  String get shoppingListReadyMessage =>
      'Connect this action to your shopping-list flow next.';

  @override
  String get planRefreshRequestedTitle => 'Plan refresh requested';

  @override
  String get planRefreshRequestedMessage =>
      'Swap this placeholder with your AI meal-generation flow.';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fats => 'Fats';

  @override
  String get notifications => 'Notifications';

  @override
  String notificationsUnreadSummary(int count) {
    return '$count unread updates from your AI meal planner';
  }

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get stayOnTopPlan => 'Stay on top of your plan';

  @override
  String get notificationsIntroDescription =>
      'Meal reminders, calorie insights, hydration alerts, and AI updates all show here.';

  @override
  String get breakfastReminder => 'Breakfast reminder';

  @override
  String get breakfastReminderMessage =>
      'Your high-protein breakfast window starts in 20 minutes.';

  @override
  String get caloriesOnTrack => 'Calories on track';

  @override
  String get caloriesOnTrackMessage =>
      'You stayed within your calorie target for 3 days in a row.';

  @override
  String get hydrationReminder => 'Hydration reminder';

  @override
  String get hydrationReminderMessage =>
      'Drink one more glass of water to stay on pace for today.';

  @override
  String get aiPlanUpdated => 'AI plan updated';

  @override
  String get aiPlanUpdatedMessage =>
      'Your lunch recommendation was adjusted for better protein balance.';

  @override
  String get weeklyInsightReady => 'Weekly insight ready';

  @override
  String get weeklyInsightReadyMessage =>
      'Your weekly nutrition trend is available to review.';

  @override
  String get subscriptionRenewed => 'Subscription renewed';

  @override
  String get subscriptionRenewedMessage =>
      'Your AI Diet Planner premium plan is active for another month.';

  @override
  String todayTimeLabel(String time) {
    return 'Today • $time';
  }

  @override
  String yesterdayTimeLabel(String time) {
    return 'Yesterday • $time';
  }

  @override
  String monthDayTimeLabel(String monthDay, String time) {
    return '$monthDay • $time';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settingsDescription =>
      'Manage your account, privacy, and subscription';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle =>
      'Switch the app language between English and Urdu';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get english => 'English';

  @override
  String get urdu => 'Urdu';

  @override
  String get languageChangedTitle => 'Language updated';

  @override
  String get languageChangedMessage => 'The app language has been changed.';

  @override
  String get accountSection => 'Account';

  @override
  String get subscriptionSection => 'Subscription Plan';

  @override
  String get availableSubscriptionSection => 'Available Subscription';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get privacySecuritySection => 'Privacy & Security';

  @override
  String get supportSection => 'Support';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get personalDetailsSubtitle => 'Name, email, and profile preferences';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Update your account password securely';

  @override
  String get connectedDevices => 'Connected devices';

  @override
  String get connectedDevicesSubtitle => 'Manage sessions across your devices';

  @override
  String get activeDevicesBadge => '2 active';

  @override
  String get mealReminders => 'Meal reminders';

  @override
  String get mealRemindersSubtitle =>
      'Breakfast, lunch, dinner, and snack alerts';

  @override
  String get hydrationReminders => 'Hydration reminders';

  @override
  String get hydrationRemindersSubtitle => 'Keep daily water goals on track';

  @override
  String get weeklyInsights => 'Weekly insights';

  @override
  String get weeklyInsightsSubtitle => 'Get progress reports every Sunday';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle =>
      'Switch between light and dark theme for the app';

  @override
  String get biometricLock => 'Biometric lock';

  @override
  String get biometricLockSubtitle =>
      'Require Face ID or fingerprint to open app';

  @override
  String get marketingEmails => 'Marketing emails';

  @override
  String get marketingEmailsSubtitle => 'Product updates, offers, and app news';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicySubtitle =>
      'How your nutrition data is used and protected';

  @override
  String get helpCenter => 'Help center';

  @override
  String get helpCenterSubtitle => 'FAQs, troubleshooting, and guidance';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get contactSupportSubtitle =>
      'Reach the team for billing or account help';

  @override
  String get appVersion => 'App version';

  @override
  String get appVersionSubtitle => 'AI Diet Planner 1.0.0';

  @override
  String get logOut => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get premiumPlanSubtitle =>
      'Unlock expert guidance and advanced AI planning';

  @override
  String get viewPerks => 'View perks';

  @override
  String get viewPlan => 'View plan';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get profileSubscriptionAiAccess => 'AI Access';

  @override
  String get profileSubscriptionDietitian => 'Dietitian';

  @override
  String get profileSubscriptionSupport => 'Support';

  @override
  String get subscriptionUnlimited => 'Unlimited';

  @override
  String get subscriptionIncluded => 'Included';

  @override
  String get subscriptionPriority => 'Priority';

  @override
  String get availableSubscriptionTitle => 'Available Subscription';

  @override
  String get availableSubscriptionDescription =>
      'Upgrade to Premium for expert support, stronger AI planning, and deeper health insights.';

  @override
  String get premium => 'PREMIUM';

  @override
  String get premiumActive => 'PREMIUM ACTIVE';

  @override
  String get monthlyBilling => 'Monthly billing';

  @override
  String get premiumDescription =>
      'Unlock expert guidance, deeper AI personalization, and long-term planning tools built for measurable progress.';

  @override
  String get highlightUnlimitedAiChat => 'Unlimited AI chat';

  @override
  String get highlightDietitianConsults => 'Dietitian consults';

  @override
  String get highlightPrioritySupport => 'Priority support';

  @override
  String get activatePremium => 'Activate Premium';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get premiumBenefits => 'Premium benefits';

  @override
  String get premiumBenefitsDescription =>
      'These features are available only to Premium users.';

  @override
  String get professionalDietitianConsultations =>
      'Professional Dietitian Consultations';

  @override
  String get professionalDietitianConsultationsDescription =>
      'Direct access to certified nutrition experts.';

  @override
  String get advancedAiOptimization => 'Advanced AI Optimization';

  @override
  String get advancedAiOptimizationDescription =>
      'AI-generated meal plans with enhanced personalization and efficiency for faster results.';

  @override
  String get personalizedLongTermPlans => 'Personalized Long-Term Plans';

  @override
  String get personalizedLongTermPlansDescription =>
      'Customized weekly or monthly diet plans tailored to user health goals.';

  @override
  String get unlimitedAiChatbotAccess => 'Unlimited AI Chatbot Access';

  @override
  String get unlimitedAiChatbotAccessDescription =>
      'Full access to AI guidance without the limitations guest or free users have.';

  @override
  String get prioritySupport => 'Priority Support';

  @override
  String get prioritySupportDescription =>
      'Faster responses and support for app-related issues.';

  @override
  String get enhancedAnalyticsInsights => 'Enhanced Analytics & Insights';

  @override
  String get enhancedAnalyticsInsightsDescription =>
      'Advanced progress tracking, trend analysis, and richer nutrition insights.';

  @override
  String get managePlan => 'Manage plan';

  @override
  String get openSettings => 'Open settings';

  @override
  String get viewBenefits => 'View benefits';

  @override
  String nextBillingDate(String date) {
    return 'Next billing date: $date';
  }

  @override
  String get premiumAlreadyActiveTitle => 'Premium already active';

  @override
  String get premiumAlreadyActiveMessage =>
      'Your premium plan is already enabled on this account.';

  @override
  String get premiumActivatedTitle => 'Premium activated';

  @override
  String get premiumActivatedMessage =>
      'Your premium subscription is now active across the app.';

  @override
  String get manageSubscriptionTitle => 'Manage subscription';

  @override
  String manageSubscriptionMessage(String date) {
    return 'Next billing date: $date';
  }

  @override
  String get setUpYourProfile => 'Set Up Your Profile';

  @override
  String get completeSetup => 'Complete setup';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get nextButton => 'Next';

  @override
  String get backButton => 'Back';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get profileUpdatedTitle => 'Profile updated';

  @override
  String get profileUpdatedMessage => 'Your nutrition preferences are saved.';

  @override
  String get finishProfileSetupMessage =>
      'Complete your profile so AI meals match your body, goals, and food restrictions.';

  @override
  String profileSetupStepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get setupSkippedTitle => 'Setup skipped';

  @override
  String get setupSkippedMessage =>
      'You can complete your profile later from the Profile tab.';

  @override
  String get completeRequiredFieldsTitle => 'Complete required details';

  @override
  String get completeRequiredFieldsMessage =>
      'Add your age, weight, height, activity level, and goal before continuing.';

  @override
  String get completeYourProfileTitle => 'Complete your profile';

  @override
  String get completeYourProfileMessage =>
      'Add your body stats, goals, and food restrictions so AI meal planning is safer and more accurate.';

  @override
  String get resumeSetup => 'Complete now';

  @override
  String get profileIntroDescription =>
      'Help us personalize your nutrition plan';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get healthMetrics => 'Health Metrics';

  @override
  String get bmiAutoCalculated => 'BMI (Auto-calculated)';

  @override
  String get normal => 'Normal';

  @override
  String get underweight => 'Underweight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get notEnoughData => 'Not enough data';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get selectActivityLevel => 'Select activity level';

  @override
  String get lightlyActive => 'Lightly Active';

  @override
  String get moderatelyActive => 'Moderately Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get yourFitnessGoals => 'Your Fitness Goals';

  @override
  String get loseWeight => 'Lose Weight';

  @override
  String get maintainWeight => 'Maintain Weight';

  @override
  String get gainMuscle => 'Gain Muscle';

  @override
  String get foodPreferences => 'Food Preferences';

  @override
  String get foodPreferencesSubtitle =>
      'These selections help AI avoid unsafe ingredients and tailor your meals.';

  @override
  String get dietPreference => 'Diet Preference';

  @override
  String get selectDietPreference => 'Select diet preference';

  @override
  String get balancedDiet => 'Balanced';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get vegan => 'Vegan';

  @override
  String get halal => 'Halal';

  @override
  String get keto => 'Keto';

  @override
  String get highProteinDiet => 'High Protein';

  @override
  String get allergiesAndAvoidances => 'Allergies & Avoidances';

  @override
  String get allergiesSelectionHint =>
      'Choose anything the AI must never include.';

  @override
  String get peanuts => 'Peanuts';

  @override
  String get treeNuts => 'Tree Nuts';

  @override
  String get dairy => 'Dairy';

  @override
  String get eggs => 'Eggs';

  @override
  String get shellfish => 'Shellfish';

  @override
  String get fish => 'Fish';

  @override
  String get soy => 'Soy';

  @override
  String get wheat => 'Wheat';

  @override
  String get sesame => 'Sesame';

  @override
  String get dislikedFoods => 'Disliked Foods';

  @override
  String get dislikedFoodsHint => 'Ex: mushrooms, olives, liver';

  @override
  String get allergySafetyNote =>
      'Selected allergens should be excluded from AI meal suggestions.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmailRequired => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get confirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loggedOutTitle => 'Logged out';

  @override
  String get loggedOutMessage => 'See you again soon.';

  @override
  String get welcomeBackTitle => 'Welcome back';

  @override
  String get mealPlannerReadyMessage => 'Your meal planner is ready.';

  @override
  String get googleSignInTitle => 'Google sign-in';

  @override
  String get googleSignInMessage => 'Connect the real Google auth flow next.';

  @override
  String get accountCreatedTitle => 'Account created';

  @override
  String get accountCreatedMessage =>
      'Welcome to your AI diet planner journey.';

  @override
  String get googleSignUpTitle => 'Google sign-up';

  @override
  String get googleSignUpMessage =>
      'Connect the real Google onboarding flow next.';

  @override
  String get helpCenterMessage =>
      'This area is ready for FAQ content or customer support links.';

  @override
  String get contactSupportMessage => 'Email: support@aimealplanner.app';

  @override
  String get privacyPolicyMessage =>
      'This can later open a webview or markdown page with your policy.';

  @override
  String get personalDetailsMessage =>
      'Connect this tile to your profile edit flow when you are ready.';

  @override
  String get connectedDevicesMessage =>
      'Phone and tablet are currently signed in to this account.';

  @override
  String get premiumBenefitsMessage =>
      'Dietitian consultations, advanced AI optimization, long-term plans, unlimited chatbot access, priority support, and enhanced insights are included.';

  @override
  String get guestModeTitle => 'Sign In to Continue';

  @override
  String get guestModeDescription =>
      'Create an account or sign in to unlock personalized meal plans, detailed nutrition insights, and progress tracking.';

  @override
  String get guestModeButtonSignIn => 'Sign In or Create Account';

  @override
  String get guestModeSecondaryButton => 'Continue Exploring';

  @override
  String get dietPlanGuestTitle => 'Sign in to view meal plans';

  @override
  String get dietPlanGuestDescription =>
      'Create an account or sign in to access your personalized meal plan and keep your progress synced.';

  @override
  String get dataPreviewTitle => 'Data Preview';

  @override
  String get dataPreviewDescription =>
      'Sign in to see your nutrition data and detailed analytics';

  @override
  String get upgradeForAnalytics =>
      'Sign in to unlock detailed nutrition analytics';
}
