// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nudget';

  @override
  String get navHome => 'Home';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navCategories => 'Categories';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String spentThisPeriod(String period) {
    return 'Spent this $period';
  }

  @override
  String get recentExpenses => 'Recent expenses';

  @override
  String get filteredExpenses => 'Filtered expenses';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get seeAll => 'See all';

  @override
  String get allExpenses => 'All expenses';

  @override
  String get pendingClassification => 'Pending Classification';

  @override
  String get pendingClassificationTooltip => 'Pending classification';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noPendingExpenses => 'No expenses waiting to be classified.';

  @override
  String get deleteExpenseTitle => 'Delete expense?';

  @override
  String get cannotBeUndone => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get amountLabel => 'Amount (€)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get uncategorised => 'Uncategorised';

  @override
  String get dateLabel => 'Date';

  @override
  String get sourceLabel => 'Source';

  @override
  String get originalTextLabel => 'Original text';

  @override
  String get required => 'Required';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get assignCategory => 'Assign category';

  @override
  String get rememberForSimilar => 'Remember for similar expenses';

  @override
  String get rememberForSimilarDesc =>
      'Creates a rule to auto-classify future expenses from the same source.';

  @override
  String get classifyAndSaveRule => 'Classify & save rule';

  @override
  String get classify => 'Classify';

  @override
  String get addExpense => 'Add expense';

  @override
  String get newExpense => 'New expense';

  @override
  String get addCategory => 'Add category';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get tapToCreateCategory => 'Tap + to create your first category.';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get nameLabel => 'Name';

  @override
  String get spendingLimitLabel => 'Spending limit (€, optional)';

  @override
  String get nameHint => 'e.g. Groceries';

  @override
  String get limitHint => 'e.g. 300';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get enterPositiveNumber => 'Enter a positive number';

  @override
  String get colorLabel => 'Color';

  @override
  String get iconLabel => 'Icon';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get create => 'Create';

  @override
  String get allFilter => 'All';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noExpensesMatchFilter => 'No expenses match the filter';

  @override
  String get tryAdjustingFilter => 'Try adjusting the category or date range.';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get topCategories => 'Top categories';

  @override
  String get categoryBreakdown => 'Category breakdown';

  @override
  String get noSpendingData => 'No spending data for the last 6 months';

  @override
  String get noExpensesThisMonth => 'No expenses recorded this month.';

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String get notificationSourcesTitle => 'Notification sources';

  @override
  String get addNotificationSource => 'Add source';

  @override
  String get newNotificationSource => 'New source';

  @override
  String get editNotificationSource => 'Edit source';

  @override
  String get appNameLabel => 'App name';

  @override
  String get patternLabel => 'Pattern';

  @override
  String patternHint(String importe, String concepto) {
    return 'e.g. Pago de $importe€ en $concepto';
  }

  @override
  String patternRequiresAmount(String importe) {
    return 'Pattern must include $importe';
  }

  @override
  String get testPatternLabel => 'Test notification';

  @override
  String get testPatternHint => 'Paste a sample notification…';

  @override
  String patternMatchAmount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String patternMatchMerchant(String merchant) {
    return 'Merchant: $merchant';
  }

  @override
  String get patternNoMatch => 'Pattern does not match';

  @override
  String get enabledLabel => 'Active';

  @override
  String get selectFromRecent => 'Recent apps';

  @override
  String get noNotificationSources => 'No sources configured yet';

  @override
  String get automationSection => 'Automation';

  @override
  String failedToSaveSource(String error) {
    return 'Failed to save source: $error';
  }

  @override
  String failedToDeleteSource(String error) {
    return 'Failed to delete source: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSection => 'Profile';

  @override
  String get editProfileName => 'Name';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get manageNotificationAccess => 'Manage access';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageGalician => 'Galician';

  @override
  String get notificationAccessTitle => 'Notification access';

  @override
  String get notificationAccessContent =>
      'Nudget reads your payment notifications to log expenses automatically. Grant \"Notification access\" in the next screen to enable this feature.\n\nYou can still add expenses manually without this permission.';

  @override
  String get notNow => 'Not now';

  @override
  String get allow => 'Allow';

  @override
  String failedToSaveCategory(String error) {
    return 'Failed to save category: $error';
  }

  @override
  String failedToDeleteCategory(String error) {
    return 'Failed to delete category: $error';
  }

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String failedToClassify(String error) {
    return 'Failed to classify: $error';
  }

  @override
  String get couldNotLoadExpenses => 'Could not load expenses';

  @override
  String get couldNotLoadPendingExpenses => 'Could not load pending expenses';

  @override
  String get couldNotLoadCategories => 'Could not load categories';
}
