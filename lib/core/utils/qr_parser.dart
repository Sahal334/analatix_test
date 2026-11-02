sealed class QrResult {
  const QrResult();

  const factory QrResult.product(int id) = QrResultProduct;

  const factory QrResult.invalidFormat() = QrResultInvalidFormat;

  const factory QrResult.notAProduct() = QrResultNotAProduct;
}

final class QrResultProduct extends QrResult {
  const QrResultProduct(this.id);
  final int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is QrResultProduct && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QrResult.product($id)';
}

final class QrResultInvalidFormat extends QrResult {
  const QrResultInvalidFormat();

  @override
  String toString() => 'QrResult.invalidFormat()';
}

final class QrResultNotAProduct extends QrResult {
  const QrResultNotAProduct();

  @override
  String toString() => 'QrResult.notAProduct()';
}

QrResult parseQrCode(String code) {
  if (code.isEmpty) return const QrResult.invalidFormat();

  final Uri uri;
  try {
    uri = Uri.parse(code);
  } catch (_) {
    return const QrResult.invalidFormat();
  }

  if (uri.scheme != 'catalogue' || uri.host != 'product') {
    return const QrResult.notAProduct();
  }

  final segments = uri.pathSegments;
  if (segments.isEmpty) return const QrResult.invalidFormat();

  final idSegment = segments.last;
  final id = int.tryParse(idSegment);
  if (id == null) return const QrResult.invalidFormat();

  return QrResult.product(id);
}
