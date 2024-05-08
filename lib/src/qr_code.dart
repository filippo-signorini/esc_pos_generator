import 'package:esc_pos_generator/src/commands.dart';
import 'package:esc_pos_generator/src/enums.dart';
import 'package:esc_pos_generator/src/utils.dart';

enum QRSize {
  s1(1),
  s2(2),
  s3(3),
  s4(4),
  s5(5),
  s6(6),
  s7(7),
  s8(8),
  s9(9),
  s10(10),
  s11(11),
  s12(12),
  s13(13),
  s14(14),
  s15(15),
  s16(16);

  const QRSize(this._value);
  final int _value;

  List<int> get bytes => [...qrCodeSize.codeUnits, _value];
}

enum QRCorrection {
  l,
  m,
  q,
  h;

  int _getValue(PrinterType printerType) => switch (printerType) {
        PrinterType.sunmi ||
        PrinterType.sunmiPos ||
        PrinterType.epson =>
          switch (this) { l => 48, m => 49, q => 50, h => 51 },
        PrinterType.custom => switch (this) {
            l => 1,
            m => 2,
            q => 3,
            h => 4,
          }
      };

  List<int> getBytes(PrinterType printerType) {
    return [...qrCodeCorrection.codeUnits, _getValue(printerType)];
  }
}

class QRCode {
  final QRSize size;
  final QRCorrection correction;
  final String data;

  QRCode(String data, {this.size = QRSize.s4, this.correction = QRCorrection.l})
      : data = encodeString(data);

  List<int> getBytes(PrinterType printerType) {
    List<int> bytes = [
      ...size.bytes,
      ...correction.getBytes(printerType),
      // Memorizza
      ...[
        ...qrGeneric.codeUnits,
        data.length + 3,
        0x00,
        49,
        80,
        48,
        ...data.codeUnits,
      ],
    ];

    switch (printerType) {
      case PrinterType.sunmi:
      case PrinterType.sunmiPos:
      case PrinterType.epson:
        bytes += [...qrGeneric.codeUnits, 0x03, 00, 49, 81, 48];
      case PrinterType.custom:
        bytes += [...qrGeneric.codeUnits, 0x03, 00, 49, 81, 49];
    }
    return bytes;
  }
}
