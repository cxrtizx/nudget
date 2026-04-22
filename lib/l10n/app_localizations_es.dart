// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Nudget';

  @override
  String get navHome => 'Inicio';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navStatistics => 'Estadísticas';

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get periodYear => 'Año';

  @override
  String spentThisPeriod(String period) {
    return 'Total: $period';
  }

  @override
  String get recentExpenses => 'Gastos recientes';

  @override
  String get filteredExpenses => 'Gastos filtrados';

  @override
  String get noExpensesYet => 'Aún no hay gastos';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get allExpenses => 'Todos los gastos';

  @override
  String get pendingClassification => 'Clasificación pendiente';

  @override
  String get pendingClassificationTooltip => 'Clasificación pendiente';

  @override
  String get allCaughtUp => '¡Al día!';

  @override
  String get noPendingExpenses => 'No hay gastos pendientes de clasificar.';

  @override
  String get deleteExpenseTitle => '¿Eliminar gasto?';

  @override
  String get cannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get amountLabel => 'Importe (€)';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get uncategorised => 'Sin categoría';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get sourceLabel => 'Origen';

  @override
  String get originalTextLabel => 'Texto original';

  @override
  String get required => 'Obligatorio';

  @override
  String get enterValidAmount => 'Introduce un importe válido';

  @override
  String get assignCategory => 'Asignar categoría';

  @override
  String get rememberForSimilar => 'Recordar para gastos similares';

  @override
  String get rememberForSimilarDesc =>
      'Crea una regla para clasificar automáticamente gastos futuros del mismo origen.';

  @override
  String get classifyAndSaveRule => 'Clasificar y guardar regla';

  @override
  String get classify => 'Clasificar';

  @override
  String get addCategory => 'Añadir categoría';

  @override
  String get noCategories => 'Aún no hay categorías';

  @override
  String get tapToCreateCategory => 'Toca + para crear tu primera categoría.';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get spendingLimitLabel => 'Límite de gasto (€, opcional)';

  @override
  String get nameHint => 'p. ej. Alimentación';

  @override
  String get limitHint => 'p. ej. 300';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get enterPositiveNumber => 'Introduce un número positivo';

  @override
  String get colorLabel => 'Color';

  @override
  String get iconLabel => 'Icono';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get create => 'Crear';

  @override
  String get allFilter => 'Todos';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get clearFilters => 'Quitar filtros';

  @override
  String get noExpensesMatchFilter => 'Ningún gasto coincide con el filtro';

  @override
  String get tryAdjustingFilter =>
      'Prueba a ajustar la categoría o el rango de fechas.';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get last6Months => 'Últimos 6 meses';

  @override
  String get topCategories => 'Principales categorías';

  @override
  String get categoryBreakdown => 'Desglose por categoría';

  @override
  String get noSpendingData => 'Sin datos de gasto en los últimos 6 meses';

  @override
  String get noExpensesThisMonth => 'No se han registrado gastos este mes.';

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
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGalician => 'Gallego';

  @override
  String get notificationAccessTitle => 'Acceso a notificaciones';

  @override
  String get notificationAccessContent =>
      'Nudget lee tus notificaciones de pago para registrar gastos automáticamente. Concede \"Acceso a notificaciones\" en la siguiente pantalla para activar esta función.\n\nTodavía puedes añadir gastos manualmente sin este permiso.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get allow => 'Permitir';

  @override
  String failedToSaveCategory(String error) {
    return 'Error al guardar la categoría: $error';
  }

  @override
  String failedToDeleteCategory(String error) {
    return 'Error al eliminar la categoría: $error';
  }

  @override
  String failedToDelete(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String failedToSave(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String failedToClassify(String error) {
    return 'Error al clasificar: $error';
  }

  @override
  String get couldNotLoadExpenses => 'No se pudieron cargar los gastos';

  @override
  String get couldNotLoadPendingExpenses =>
      'No se pudieron cargar los gastos pendientes';

  @override
  String get couldNotLoadCategories => 'No se pudieron cargar las categorías';
}
