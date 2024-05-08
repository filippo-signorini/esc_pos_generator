import 'package:test/test.dart';

import 'package:esc_pos_generator/esc_pos_generator.dart';
import 'package:esc_pos_generator/src/commands.dart' as commands;

void main() {
  test('init generator', () {
    final generator = Generator(PosPaperSize.mm80, PrinterType.sunmi);
    expect(
      generator.init(),
      [
        ...commands.reset.codeUnits,
        ...PosStyle.defaults.getBytes(generator.printerType),
      ],
    );
  });

  test('print text with default styles', () {
    final generator = Generator(PosPaperSize.mm80, PrinterType.sunmi);
    const text = 'this is a line of text';
    expect(generator.text(text), text.codeUnits);
  });
}
