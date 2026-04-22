// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appTitle => 'Nudget';

  @override
  String get navHome => 'Inicio';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navStatistics => 'Estatísticas';

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get periodYear => 'Ano';

  @override
  String spentThisPeriod(String period) {
    return 'Total: $period';
  }

  @override
  String get recentExpenses => 'Gastos recentes';

  @override
  String get filteredExpenses => 'Gastos filtrados';

  @override
  String get noExpensesYet => 'Aínda non hai gastos';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get allExpenses => 'Todos os gastos';

  @override
  String get pendingClassification => 'Clasificación pendente';

  @override
  String get pendingClassificationTooltip => 'Clasificación pendente';

  @override
  String get allCaughtUp => 'Ao día!';

  @override
  String get noPendingExpenses => 'Non hai gastos pendentes de clasificar.';

  @override
  String get deleteExpenseTitle => 'Eliminar gasto?';

  @override
  String get cannotBeUndone => 'Esta acción non se pode desfacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Gardar';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get descriptionLabel => 'Descrición';

  @override
  String get amountLabel => 'Importe (€)';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get uncategorised => 'Sen categoría';

  @override
  String get dateLabel => 'Data';

  @override
  String get sourceLabel => 'Orixe';

  @override
  String get originalTextLabel => 'Texto orixinal';

  @override
  String get required => 'Obrigatorio';

  @override
  String get enterValidAmount => 'Introduce un importe válido';

  @override
  String get assignCategory => 'Asignar categoría';

  @override
  String get rememberForSimilar => 'Lembrar para gastos similares';

  @override
  String get rememberForSimilarDesc =>
      'Crea unha regra para clasificar automaticamente gastos futuros da mesma orixe.';

  @override
  String get classifyAndSaveRule => 'Clasificar e gardar regra';

  @override
  String get classify => 'Clasificar';

  @override
  String get addCategory => 'Engadir categoría';

  @override
  String get noCategories => 'Aínda non hai categorías';

  @override
  String get tapToCreateCategory =>
      'Toca + para crear a túa primeira categoría.';

  @override
  String get newCategory => 'Nova categoría';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get nameLabel => 'Nome';

  @override
  String get spendingLimitLabel => 'Límite de gasto (€, opcional)';

  @override
  String get nameHint => 'p. ex. Alimentación';

  @override
  String get limitHint => 'p. ex. 300';

  @override
  String get nameRequired => 'O nome é obrigatorio';

  @override
  String get enterPositiveNumber => 'Introduce un número positivo';

  @override
  String get colorLabel => 'Cor';

  @override
  String get iconLabel => 'Icona';

  @override
  String get saveChanges => 'Gardar cambios';

  @override
  String get create => 'Crear';

  @override
  String get allFilter => 'Todos';

  @override
  String get filterByDate => 'Filtrar por data';

  @override
  String get clearFilters => 'Quitar filtros';

  @override
  String get noExpensesMatchFilter => 'Ningún gasto coincide co filtro';

  @override
  String get tryAdjustingFilter =>
      'Proba a axustar a categoría ou o rango de datas.';

  @override
  String get statisticsTitle => 'Estatísticas';

  @override
  String get last6Months => 'Últimos 6 meses';

  @override
  String get topCategories => 'Principais categorías';

  @override
  String get categoryBreakdown => 'Desglose por categoría';

  @override
  String get noSpendingData => 'Sen datos de gasto nos últimos 6 meses';

  @override
  String get noExpensesThisMonth => 'Non se rexistraron gastos este mes.';

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '1 gasto',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGalician => 'Galego';

  @override
  String get notificationAccessTitle => 'Acceso a notificacións';

  @override
  String get notificationAccessContent =>
      'Nudget le as túas notificacións de pago para rexistrar gastos automaticamente. Concede \"Acceso a notificacións\" na seguinte pantalla para activar esta función.\n\nAínda podes engadir gastos manualmente sen este permiso.';

  @override
  String get notNow => 'Agora non';

  @override
  String get allow => 'Permitir';

  @override
  String failedToSaveCategory(String error) {
    return 'Erro ao gardar a categoría: $error';
  }

  @override
  String failedToDeleteCategory(String error) {
    return 'Erro ao eliminar a categoría: $error';
  }

  @override
  String failedToDelete(String error) {
    return 'Erro ao eliminar: $error';
  }

  @override
  String failedToSave(String error) {
    return 'Erro ao gardar: $error';
  }

  @override
  String failedToClassify(String error) {
    return 'Erro ao clasificar: $error';
  }

  @override
  String get couldNotLoadExpenses => 'Non se puideron cargar os gastos';

  @override
  String get couldNotLoadPendingExpenses =>
      'Non se puideron cargar os gastos pendentes';

  @override
  String get couldNotLoadCategories => 'Non se puideron cargar as categorías';
}
