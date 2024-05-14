import 'package:esc_pos_generator/src/barcode.dart';
import 'package:esc_pos_generator/src/commands.dart' as commands;
import 'package:esc_pos_generator/src/enums.dart';
import 'package:esc_pos_generator/src/prepared_image.dart';
import 'package:esc_pos_generator/src/qr_code.dart';
import 'package:esc_pos_generator/src/style.dart';
import 'package:esc_pos_generator/src/utils.dart';

class Generator {
  final PosPaperSize paperSize;
  final PrinterType printerType;
  PosStyle _currentStyle = PosStyle.defaults;

  Generator(this.paperSize, this.printerType);

  int get maxCharsPerLine {
    final font = _currentStyle.fontType;
    if (paperSize == PosPaperSize.mm58) {
      return (font == null || font == PosFontType.fontA) ? 32 : 42;
    } else {
      return (font == null || font == PosFontType.fontA) ? 48 : 64;
    }
  }

  List<int> init() {
    return [
      ...commands.reset.codeUnits,
      ..._currentStyle.getBytes(printerType),
    ];
  }

  List<int> text(
    String text, {
    int linesAfter = 1,
    PosStyle? style,
    bool keepStyle = false,
  }) {
    var bytes = <int>[];
    if (style != null) {
      bytes +=
          style.merge(_currentStyle, allowNull: true).getBytes(printerType);
      if (keepStyle) {
        _currentStyle = style.merge(_currentStyle, allowNull: false);
      }
    }
    bytes += encodeString(text).codeUnits;
    if (linesAfter > 0) bytes += emptyLines(linesAfter);
    if (style != null && !keepStyle) {
      bytes +=
          _currentStyle.merge(style, allowNull: true).getBytes(printerType);
    }
    return bytes;
  }

  List<int> cut() => commands.cut.codeUnits;

  List<int> emptyLines([int lines = 1]) {
    if (lines <= 0) return [];
    return [for (int i = 0; i < lines; i++) ...commands.lf.codeUnits];
  }

  List<int> hr({bool half = false}) {
    final line = String.fromCharCode(196) *
        (half ? maxCharsPerLine ~/ 2 : maxCharsPerLine);
    return text(line, style: const PosStyle(align: PosAlign.center));
  }

  List<int> setStyle(PosStyle style) {
    final bytes =
        style.merge(_currentStyle, allowNull: true).getBytes(printerType);
    _currentStyle = style.merge(_currentStyle, allowNull: false);
    return bytes;
  }

  List<int> qr(QRCode qrCode, {PosAlign align = PosAlign.center}) {
    return [
      ...align.bytes,
      ...qrCode.getBytes(printerType),
      ..._currentStyle.align!.bytes,
    ];
  }

  List<int> barcode(Barcode barcode, {PosAlign align = PosAlign.center}) {
    return [
      ...align.bytes,
      ...barcode.getBytes(),
      ..._currentStyle.align!.bytes,
    ];
  }

  /// Print an image
  List<int> image(PreparedImage image, {PosAlign align = PosAlign.center}) {
    return [
      ...align.bytes,
      ...image.bytes,
      ..._currentStyle.align!.bytes,
    ];
  }

  List<int> testPage() {
    List<int> bytes = [];
    bytes += commands.lf.codeUnits;
    bytes += "   0 1 2 3 4 5 6 7 8 9 A B C D E F ".codeUnits;
    bytes += commands.lf.codeUnits;
    for (int i = 0; i < 0x10; i++) {
      final upperDigit = i.toRadixString(16).toUpperCase();
      bytes += '$upperDigit '.codeUnits;
      for (int j = 0; j < 0x10; j++) {
        var digit = i * 0x10 + j;
        if (digit <= 0x20) digit = 0x20;
        bytes += '${String.fromCharCode(digit)} '.codeUnits;
      }
      bytes += commands.lf.codeUnits;
    }

    return bytes;
  }
}
