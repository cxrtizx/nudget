import 'package:nudget/core/utils/logger.dart';

/// Structured result produced by [NotificationParser.parse].
class ParsedExpenseData {
  /// Creates a [ParsedExpenseData].
  const ParsedExpenseData({
    required this.amount,
    required this.description,
    required this.source,
  });

  /// Transaction amount in euros, always positive.
  final double amount;

  /// Merchant name when detectable, otherwise the cleaned notification body.
  final String description;

  /// Human-readable app name that emitted the notification.
  final String source;

  @override
  String toString() =>
      'ParsedExpenseData(amount: $amount, description: $description, source: $source)';
}

/// Extracts monetary transaction data from raw notification text.
///
/// Patterns are tried in priority order — most specific first, generic last.
/// Returns `null` when no euro amount is found in the notification body.
///
/// Supported decimal formats: `42,50` and `42.50`. Amounts may have a space
/// before the `€` or `EUR` symbol.
class NotificationParser {
  /// Creates a [NotificationParser].
  const NotificationParser();

  static const Logger _log = Logger('NotificationParser');

  // ---------------------------------------------------------------------------
  // Compiled patterns (static — compiled once, reused for every parse call)
  // ---------------------------------------------------------------------------

  /// "Pago de 42,50€ en Mercadona" / "Cargo de 42,50€ en Mercadona"
  static final RegExp _pagoCargoEnPattern = RegExp(
    r'(?:Pago|Cargo) de (\d+[,\.]\d{1,2})\s*€\s+en\s+(.+)',
    caseSensitive: false,
    unicode: true,
  );

  /// "Compra Mercadona 42,50€"
  static final RegExp _compraPattern = RegExp(
    r'Compra\s+(.+?)\s+(\d+[,\.]\d{1,2})\s*€',
    caseSensitive: false,
    unicode: true,
  );

  /// "Has realizado un pago de 42,50 €"
  static final RegExp _hasRealizadoPattern = RegExp(
    r'Has realizado un pago de (\d+[,\.]\d{1,2})\s*€',
    caseSensitive: false,
    unicode: true,
  );

  /// Generic: any number followed by € or EUR (e.g. "42,50 EUR", "42.50€")
  static final RegExp _genericAmountPattern = RegExp(
    r'(\d+[,\.]\d{1,2})\s*(?:€|EUR)',
    caseSensitive: false,
    unicode: true,
  );

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Attempts to parse [body] and extract a monetary amount and merchant name.
  ///
  /// [source] is the human-readable app name, forwarded verbatim to
  /// [ParsedExpenseData.source].
  ///
  /// Returns `null` if no amount can be extracted.
  ParsedExpenseData? parse(String body, {required String source}) {
    final trimmed = body.trim();

    // Priority 1 — "Pago/Cargo de X,XX€ en <merchant>"
    final pagoMatch = _pagoCargoEnPattern.firstMatch(trimmed);
    if (pagoMatch != null) {
      final amount = _parseAmount(pagoMatch.group(1)!);
      final merchant = pagoMatch.group(2)!.trim();
      _log.info('Matched pago/cargo pattern: $amount€ @ $merchant');
      return ParsedExpenseData(
        amount: amount,
        description: merchant,
        source: source,
      );
    }

    // Priority 2 — "Compra <merchant> X,XX€"
    final compraMatch = _compraPattern.firstMatch(trimmed);
    if (compraMatch != null) {
      final merchant = compraMatch.group(1)!.trim();
      final amount = _parseAmount(compraMatch.group(2)!);
      _log.info('Matched compra pattern: $amount€ @ $merchant');
      return ParsedExpenseData(
        amount: amount,
        description: merchant,
        source: source,
      );
    }

    // Priority 3 — "Has realizado un pago de X,XX €"
    final realizadoMatch = _hasRealizadoPattern.firstMatch(trimmed);
    if (realizadoMatch != null) {
      final amount = _parseAmount(realizadoMatch.group(1)!);
      _log.info('Matched has-realizado pattern: $amount€');
      return ParsedExpenseData(
        amount: amount,
        description: source,
        source: source,
      );
    }

    // Priority 4 — Generic: first euro amount in the text
    final genericMatch = _genericAmountPattern.firstMatch(trimmed);
    if (genericMatch != null) {
      final amount = _parseAmount(genericMatch.group(1)!);
      final description = _cleanDescription(trimmed);
      _log.info('Matched generic pattern: $amount€');
      return ParsedExpenseData(
        amount: amount,
        description: description.isNotEmpty ? description : source,
        source: source,
      );
    }

    _log.info('No amount found in: "$trimmed"');
    return null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts a locale-aware decimal string to [double].
  ///
  /// Handles both comma (`42,50`) and dot (`42.50`) decimal separators.
  double _parseAmount(String raw) =>
      double.parse(raw.replaceAll(',', '.'));

  /// Strips the euro amount and symbol from [text] to produce a plain
  /// description for the generic fallback case.
  String _cleanDescription(String text) =>
      text
          .replaceAll(_genericAmountPattern, '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
}
