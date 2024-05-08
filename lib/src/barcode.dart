import 'package:esc_pos_generator/src/commands.dart' as commands;

enum BarcodeType {
  code39._(4),
  code128._(73);

  final int value;
  const BarcodeType._(this.value);
}

enum BarcodeCodePage {
  a._('{A'),
  b._('{B'),
  c._('{C');

  final String value;
  const BarcodeCodePage._(this.value);
}

enum BarcodeTextPosition {
  noText._(0),
  above._(1),
  below._(2),
  both._(3);

  final int value;
  const BarcodeTextPosition._(this.value);
}

class Barcode {
  static const _defaultHeight = 162;
  static const _defaultWidth = 3;

  final BarcodeType type;
  final BarcodeTextPosition textPosition;
  final int height;
  final int width;
  final String data;

  Barcode._({
    required this.data,
    required this.type,
    required this.textPosition,
    required this.height,
    required this.width,
  });

  /// {@template esc_pos_generator:barcode_hw_restrictions}
  /// 1 <= [height] <= 255
  ///
  /// 2 <= [width] <= 6
  /// {@endtemplate}
  factory Barcode.code39(
    String data, {
    BarcodeTextPosition textPosition = BarcodeTextPosition.noText,
    int height = _defaultHeight,
    int width = _defaultWidth,
  }) {
    _checkHW(height, width);

    final k = data.length;
    if (k < 1 || k > 255) {
      throw Exception('Barcode: Wrong data range. 1 < k < 255');
    }

    final regex = RegExp(r'^[0-9A-Z \$\%\*\+\-\.\/]$');
    if (regex.hasMatch(data)) {
      throw Exception('Barcode: Data is not valid');
    }

    return Barcode._(
      data: data,
      type: BarcodeType.code39,
      textPosition: textPosition,
      height: height,
      width: width,
    );
  }

  factory Barcode.code128(
    String data, {
    BarcodeCodePage codePage = BarcodeCodePage.a,
    BarcodeTextPosition textPosition = BarcodeTextPosition.noText,
    int height = _defaultHeight,
    int width = _defaultWidth,
  }) {
    _checkHW(height, width);

    final n = data.length;
    if (n < 0 || n > 255) {
      throw Exception('Barcode: Wrong data range. 2 < n < 255');
    }

    for (final char in data.codeUnits) {
      if (char > 127) {
        throw Exception('Barcode: Data is not valid');
      }
    }

    return Barcode._(
      data: codePage.value + data,
      type: BarcodeType.code128,
      textPosition: textPosition,
      height: height,
      width: width,
    );
  }

  static void _checkHW(int height, int width) {
    if (height < 1 || height > 255) {
      throw Exception('Barcode: height out of range');
    }

    if (width < 2 || width > 6) {
      throw Exception('Barcode: width out of range');
    }
  }

  List<int> getBytes() {
    final dataBytes = data.codeUnits;
    List<int> bytes = [
      ...[...commands.barcodeTextPosition.codeUnits, textPosition.value],
      ...[...commands.barcodeHeight.codeUnits, height],
      ...[...commands.barcodeWidth.codeUnits, width],
      ...[...commands.barcodeData.codeUnits, type.value],
    ];
    if (type.value >= 0 && type.value <= 6) {
      bytes += [...dataBytes, 0];
    } else {
      bytes += [dataBytes.length, ...dataBytes];
    }
    return bytes;
  }
}
