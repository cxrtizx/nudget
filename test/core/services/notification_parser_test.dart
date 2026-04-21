import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/services/notification_parser.dart';

void main() {
  const parser = NotificationParser();
  const source = 'CaixaBank';

  ParsedExpenseData? parse(String body) =>
      parser.parse(body, source: source);

  group('NotificationParser', () {
    // -------------------------------------------------------------------------
    // Pattern 1 — "Pago de X,XX€ en <merchant>"
    // -------------------------------------------------------------------------
    group('pago/cargo pattern', () {
      test('parses "Pago de X,XX€ en <merchant>"', () {
        final result = parse('Pago de 42,50€ en Mercadona');
        expect(result, isNotNull);
        expect(result!.amount, 42.50);
        expect(result.description, 'Mercadona');
        expect(result.source, source);
      });

      test('parses "Cargo de X,XX€ en <merchant>"', () {
        final result = parse('Cargo de 15,99€ en Amazon');
        expect(result, isNotNull);
        expect(result!.amount, 15.99);
        expect(result.description, 'Amazon');
      });

      test('handles space before € symbol', () {
        final result = parse('Pago de 10,00 € en Repsol');
        expect(result, isNotNull);
        expect(result!.amount, 10.00);
        expect(result.description, 'Repsol');
      });

      test('handles dot decimal separator', () {
        final result = parse('Pago de 8.75€ en Starbucks');
        expect(result, isNotNull);
        expect(result!.amount, 8.75);
      });

      test('is case-insensitive on the keyword', () {
        final result = parse('pago de 5,00€ en El Corte Inglés');
        expect(result, isNotNull);
        expect(result!.amount, 5.00);
      });
    });

    // -------------------------------------------------------------------------
    // Pattern 2 — "Compra <merchant> X,XX€"
    // -------------------------------------------------------------------------
    group('compra pattern', () {
      test('parses "Compra <merchant> X,XX€"', () {
        final result = parse('Compra Carrefour 67,30€');
        expect(result, isNotNull);
        expect(result!.amount, 67.30);
        expect(result.description, 'Carrefour');
      });

      test('handles multi-word merchant name', () {
        final result = parse('Compra El Corte Inglés 120,00€');
        expect(result, isNotNull);
        expect(result!.amount, 120.00);
        expect(result.description, 'El Corte Inglés');
      });

      test('is case-insensitive', () {
        final result = parse('COMPRA Lidl 9,99€');
        expect(result, isNotNull);
        expect(result!.amount, 9.99);
      });
    });

    // -------------------------------------------------------------------------
    // Pattern 3 — "Has realizado un pago de X,XX €"
    // -------------------------------------------------------------------------
    group('has-realizado pattern', () {
      test('parses "Has realizado un pago de X,XX €"', () {
        final result = parse('Has realizado un pago de 25,00 €');
        expect(result, isNotNull);
        expect(result!.amount, 25.00);
        // No merchant — falls back to source
        expect(result.description, source);
      });

      test('parses without space before €', () {
        final result = parse('Has realizado un pago de 3,49€');
        expect(result, isNotNull);
        expect(result!.amount, 3.49);
      });
    });

    // -------------------------------------------------------------------------
    // Pattern 4 — Generic: any number followed by € or EUR
    // -------------------------------------------------------------------------
    group('generic pattern', () {
      test('extracts first euro amount from arbitrary text', () {
        final result = parse('Transacción confirmada: 55,00 EUR');
        expect(result, isNotNull);
        expect(result!.amount, 55.00);
      });

      test('handles EUR symbol', () {
        final result = parse('Payment 19.99 EUR processed');
        expect(result, isNotNull);
        expect(result!.amount, 19.99);
      });

      test('handles amount without leading context', () {
        final result = parse('33,00€ cobrados');
        expect(result, isNotNull);
        expect(result!.amount, 33.00);
      });
    });

    // -------------------------------------------------------------------------
    // No match
    // -------------------------------------------------------------------------
    group('no match', () {
      test('returns null when no amount is present', () {
        expect(parse('Your package has been shipped'), isNull);
      });

      test('returns null for empty string', () {
        expect(parse(''), isNull);
      });

      test('returns null for plain number without currency symbol', () {
        expect(parse('Reference: 4250'), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Source forwarding
    // -------------------------------------------------------------------------
    test('always forwards source to ParsedExpenseData', () {
      final result = parse('Pago de 10,00€ en Repsol');
      expect(result!.source, source);
    });

    // -------------------------------------------------------------------------
    // Priority: specific patterns win over generic
    // -------------------------------------------------------------------------
    test('pago/cargo takes priority over generic fallback', () {
      // Contains a generic amount but should match pago pattern first.
      final result = parse('Pago de 42,50€ en Mercadona — ref 9,99 EUR');
      expect(result!.amount, 42.50);
      expect(result.description, 'Mercadona — ref 9,99 EUR');
    });
  });
}
