import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_gl.dart';

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
    Locale('es'),
    Locale('gl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nudget'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @spentThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Spent this {period}'**
  String spentThisPeriod(String period);

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent expenses'**
  String get recentExpenses;

  /// No description provided for @filteredExpenses.
  ///
  /// In en, this message translates to:
  /// **'Filtered expenses'**
  String get filteredExpenses;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All expenses'**
  String get allExpenses;

  /// No description provided for @pendingClassification.
  ///
  /// In en, this message translates to:
  /// **'Pending Classification'**
  String get pendingClassification;

  /// No description provided for @pendingClassificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pending classification'**
  String get pendingClassificationTooltip;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noPendingExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses waiting to be classified.'**
  String get noPendingExpenses;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (€)'**
  String get amountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @uncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get uncategorised;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @originalTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Original text'**
  String get originalTextLabel;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @assignCategory.
  ///
  /// In en, this message translates to:
  /// **'Assign category'**
  String get assignCategory;

  /// No description provided for @rememberForSimilar.
  ///
  /// In en, this message translates to:
  /// **'Remember for similar expenses'**
  String get rememberForSimilar;

  /// No description provided for @rememberForSimilarDesc.
  ///
  /// In en, this message translates to:
  /// **'Creates a rule to auto-classify future expenses from the same source.'**
  String get rememberForSimilarDesc;

  /// No description provided for @classifyAndSaveRule.
  ///
  /// In en, this message translates to:
  /// **'Classify & save rule'**
  String get classifyAndSaveRule;

  /// No description provided for @classify.
  ///
  /// In en, this message translates to:
  /// **'Classify'**
  String get classify;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpense;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @tapToCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first category.'**
  String get tapToCreateCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @spendingLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Spending limit (€, optional)'**
  String get spendingLimitLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get nameHint;

  /// No description provided for @limitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 300'**
  String get limitHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get enterPositiveNumber;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noExpensesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No expenses match the filter'**
  String get noExpensesMatchFilter;

  /// No description provided for @tryAdjustingFilter.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the category or date range.'**
  String get tryAdjustingFilter;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get topCategories;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get categoryBreakdown;

  /// No description provided for @noSpendingData.
  ///
  /// In en, this message translates to:
  /// **'No spending data for the last 6 months'**
  String get noSpendingData;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded this month.'**
  String get noExpensesThisMonth;

  /// No description provided for @expenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String expenseCount(int count);

  /// No description provided for @notificationSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification sources'**
  String get notificationSourcesTitle;

  /// No description provided for @addNotificationSource.
  ///
  /// In en, this message translates to:
  /// **'Add source'**
  String get addNotificationSource;

  /// No description provided for @newNotificationSource.
  ///
  /// In en, this message translates to:
  /// **'New source'**
  String get newNotificationSource;

  /// No description provided for @editNotificationSource.
  ///
  /// In en, this message translates to:
  /// **'Edit source'**
  String get editNotificationSource;

  /// No description provided for @appNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get appNameLabel;

  /// No description provided for @patternLabel.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternLabel;

  /// No description provided for @patternHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pago de {importe}€ en {concepto}'**
  String patternHint(String importe, String concepto);

  /// No description provided for @patternRequiresAmount.
  ///
  /// In en, this message translates to:
  /// **'Pattern must include {importe}'**
  String patternRequiresAmount(String importe);

  /// No description provided for @testPatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get testPatternLabel;

  /// No description provided for @testPatternHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a sample notification…'**
  String get testPatternHint;

  /// No description provided for @patternMatchAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String patternMatchAmount(String amount);

  /// No description provided for @patternMatchMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant: {merchant}'**
  String patternMatchMerchant(String merchant);

  /// No description provided for @patternNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Pattern does not match'**
  String get patternNoMatch;

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get enabledLabel;

  /// No description provided for @selectFromRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent apps'**
  String get selectFromRecent;

  /// No description provided for @noNotificationSources.
  ///
  /// In en, this message translates to:
  /// **'No sources configured yet'**
  String get noNotificationSources;

  /// No description provided for @automationSection.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get automationSection;

  /// No description provided for @failedToSaveSource.
  ///
  /// In en, this message translates to:
  /// **'Failed to save source: {error}'**
  String failedToSaveSource(String error);

  /// No description provided for @failedToDeleteSource.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete source: {error}'**
  String failedToDeleteSource(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileName;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @manageNotificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage access'**
  String get manageNotificationAccess;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageGalician.
  ///
  /// In en, this message translates to:
  /// **'Galician'**
  String get languageGalician;

  /// No description provided for @notificationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification access'**
  String get notificationAccessTitle;

  /// No description provided for @notificationAccessContent.
  ///
  /// In en, this message translates to:
  /// **'Nudget reads your payment notifications to log expenses automatically. Grant \"Notification access\" in the next screen to enable this feature.\n\nYou can still add expenses manually without this permission.'**
  String get notificationAccessContent;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @failedToSaveCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to save category: {error}'**
  String failedToSaveCategory(String error);

  /// No description provided for @failedToDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category: {error}'**
  String failedToDeleteCategory(String error);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @failedToClassify.
  ///
  /// In en, this message translates to:
  /// **'Failed to classify: {error}'**
  String failedToClassify(String error);

  /// No description provided for @couldNotLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Could not load expenses'**
  String get couldNotLoadExpenses;

  /// No description provided for @couldNotLoadPendingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Could not load pending expenses'**
  String get couldNotLoadPendingExpenses;

  /// No description provided for @couldNotLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get couldNotLoadCategories;
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
      <String>['en', 'es', 'gl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'gl':
      return AppLocalizationsGl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
