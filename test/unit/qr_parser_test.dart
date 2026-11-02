import 'package:flutter_test/flutter_test.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/utils/qr_parser.dart';

void main() {
  group('QR Code Parser Tests', () {
    test('Valid QR code catalogue://product/3 parses to product 3', () {
      final result = parseQrCode('catalogue://product/3');
      expect(result, isA<QrResultProduct>());
      expect((result as QrResultProduct).id, equals(3));
    });

    test('Valid QR code catalogue://product/15 parses to product 15', () {
      final result = parseQrCode('catalogue://product/15');
      expect(result, isA<QrResultProduct>());
      expect((result as QrResultProduct).id, equals(15));
    });

    test('Valid QR code catalogue://product/9999 parses to product 9999', () {
      final result = parseQrCode('catalogue://product/9999');
      expect(result, isA<QrResultProduct>());
      expect((result as QrResultProduct).id, equals(9999));
    });

    test('Non-product QR code https://example.com returns notAProduct', () {
      final result = parseQrCode('https://example.com');
      expect(result, isA<QrResultNotAProduct>());
    });

    test('Non-product scheme ftp://product/3 returns notAProduct', () {
      final result = parseQrCode('ftp://product/3');
      expect(result, isA<QrResultNotAProduct>());
    });

    test('Invalid id segment catalogue://product/abc returns invalidFormat', () {
      final result = parseQrCode('catalogue://product/abc');
      expect(result, isA<QrResultInvalidFormat>());
    });

    test('Empty string returns invalidFormat', () {
      final result = parseQrCode('');
      expect(result, isA<QrResultInvalidFormat>());
    });
  });
}

