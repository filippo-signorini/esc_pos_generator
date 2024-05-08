import 'package:flutter/material.dart';
import 'package:esc_pos_generator/esc_pos_generator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _test,
            child: const Text('Print Test'),
          ),
        ),
      ),
    );
  }

  void _test() async {
    final printer = FlutterUsbPrinter();
    await printer.connect(4070, 33054);

    const channel =
        MethodChannel('it.elsyco.touchticket_webview/sunmi_printer');
    final gen = Generator(PosPaperSize.mm80, PrinterType.epson);

    var bytes = <int>[];
    bytes += gen.init();
    // bytes += gen.setStyle(const PosStyle(
    //   align: PosAlign.center,
    //   doubleHeight: true,
    //   bold: true,
    // ));
    // bytes += gen.text('TOUCH TICKET');
    // final note1 = [
    //   'ELSYCO INFORMATICA SRL',
    //   'Via B. Ramazzini 27/R',
    //   '50135 FIRENZE (FI)',
    //   'Tel: 055 669969',
    // ];
    // bytes += gen.setStyle(const PosStyle(doubleHeight: false, bold: false));
    // for (final line in note1) {
    //   bytes += gen.text(line);
    // }
    // bytes += gen.hr();
    // bytes += gen.text(
    //   "Emissione ai sensi: Art. 1 D.M. 4/8/93\nArt. 2 lett 'gg' DPR 969/96",
    //   linesAfter: 2,
    // );
    // final note2 = [
    //   'ORARIO LUN-SAB 7:00-10:00',
    //   'DOM. E FESTIVI 7:00-10:00',
    // ];
    // bytes += gen.setStyle(const PosStyle(bold: true));
    // for (final line in note2) {
    //   bytes += gen.text(line);
    // }
    // bytes += gen.emptyLines(1);
    // bytes += gen.qr(QRCode('https://gestioneazienda.net', size: QRSize.s6));
    // bytes += gen.emptyLines(2);
    // bytes += gen.text(
    //   'N. Ric: ',
    //   style: PosStyle.defaults.copyWith(
    //     align: PosAlign.left,
    //     doubleHeight: true,
    //     bold: true,
    //   ),
    //   keepStyle: true,
    //   linesAfter: 0,
    // );
    // bytes += gen.text('15', style: const PosStyle(doubleWidth: true));
    // bytes += gen.emptyLines(1);
    bytes += gen.setStyle(const PosStyle(bold: true, doubleWidth: true));
    bytes += gen.text(
      'Targa: ',
      style: PosStyle.defaults.copyWith(doubleWidth: true, bold: true),
      linesAfter: 0,
    );
    bytes += gen.text(
      'GG',
      style: const PosStyle(doubleHeight: true),
      linesAfter: 0,
    );
    bytes += gen.text(
      '777',
      style: const PosStyle(fontType: PosFontType.fontB, doubleWidth: false),
      linesAfter: 0,
    );
    bytes += gen.text(
      'DL',
      style: const PosStyle(doubleHeight: true),
    );
    bytes += gen.text(' Tipo: AUDI A1');
    bytes += gen.emptyLines(1);
    // bytes += gen.setStyle(const PosStyle(align: PosAlign.center));
    // bytes += gen.barcode(Barcode.code39('0025000336', height: 80));

    // final imageBytes = Uint8List.sublistView(
    //   await rootBundle.load('assets/amort.jpg'),
    // );
    // bytes += gen.image(await PreparedImage.fromBytes(
    //   bytes: imageBytes,
    //   printerType: gen.printerType,
    // ));
    bytes += gen.cut();

    await printer.write(Uint8List.fromList(bytes));

    // return channel.invokeMethod('print', Uint8List.fromList(bytes));
  }
}
