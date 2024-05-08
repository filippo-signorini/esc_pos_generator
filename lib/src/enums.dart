enum PrinterType { sunmi, sunmiPos, epson, custom }

enum PosPaperSize {
  mm58,
  mm80;

  int get width => switch (this) {
        mm58 => 372,
        mm80 => 558,
      };
}
