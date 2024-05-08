import 'package:esc_pos_generator/src/commands.dart' as commands;
import 'package:esc_pos_generator/src/enums.dart';

enum PosFontType { fontA, fontB }

enum PosAlign {
  left(0),
  center(1),
  right(2);

  const PosAlign(this._value);
  final int _value;

  List<int> get bytes => [...commands.align.codeUnits, _value];
}

enum PosRotation {
  r0(0),
  r90(1),

  /// **SOLO SUNMI**
  r180(2),

  /// **SOLO SUNMI**
  r270(3);

  const PosRotation(this._value);
  final int _value;

  List<int> get bytes => [...commands.rotation.codeUnits, _value];
}

enum PosTextSize {
  size1(0),
  size2(1),
  size3(2),
  size4(3),
  size5(4),
  size6(5),
  size7(6),
  size8(7);

  const PosTextSize(this._value);
  final int _value;

  int get widthValue => _value << 4;
  int get heightValue => _value;
}

class PosStyle {
  const PosStyle({
    this.bold,
    this.doubleHeight,
    this.doubleWidth,
    this.height,
    this.width,
    this.underline,
    this.align,
    this.fontType,
    this.italic,
    this.upsideDown,
    this.rotation,
    this.inverted,
  });

  final bool? bold;
  final bool? doubleHeight;
  final bool? doubleWidth;
  final PosTextSize? height;
  final PosTextSize? width;
  final bool? underline;
  final PosAlign? align;

  /// **NO SUNMI**
  final PosFontType? fontType;

  /// **NO SUNMI**
  final bool? italic;
  final bool? upsideDown;
  final PosRotation? rotation;
  final bool? inverted;

  static const defaults = PosStyle(
    bold: false,
    doubleHeight: false,
    doubleWidth: false,
    underline: false,
    align: PosAlign.left,
    fontType: PosFontType.fontA,
    italic: false,
    upsideDown: false,
    inverted: false,
  );

  PosStyle merge(PosStyle other, {required bool allowNull}) {
    return PosStyle(
      bold: _getPar(bold, other.bold, allowNull: allowNull),
      doubleHeight: _getPar(
        doubleHeight,
        other.doubleHeight,
        allowNull: allowNull,
      ),
      doubleWidth: _getPar(
        doubleWidth,
        other.doubleWidth,
        allowNull: allowNull,
      ),
      height: _getPar(height, other.height, allowNull: allowNull),
      width: _getPar(width, other.width, allowNull: allowNull),
      underline: _getPar(underline, other.underline, allowNull: allowNull),
      align: _getPar(align, other.align, allowNull: allowNull),
      fontType: _getPar(fontType, other.fontType, allowNull: allowNull),
      italic: _getPar(italic, other.italic, allowNull: allowNull),
      upsideDown: _getPar(upsideDown, other.upsideDown, allowNull: allowNull),
      rotation: _getPar(rotation, other.rotation, allowNull: allowNull),
      inverted: _getPar(inverted, other.inverted, allowNull: allowNull),
    );
  }

  PosStyle copyWith({
    bool? bold,
    bool? doubleHeight,
    bool? doubleWidth,
    PosTextSize? height,
    PosTextSize? width,
    bool? underline,
    PosAlign? align,

    /// **NO SUNMI**
    PosFontType? fontType,

    /// **NO SUNMI**
    bool? italic,
    bool? upsideDown,
    PosRotation? rotation,
    bool? inverted,
  }) =>
      PosStyle(
        bold: bold ?? this.bold,
        doubleHeight: doubleHeight ?? this.doubleHeight,
        doubleWidth: doubleWidth ?? this.doubleWidth,
        height: height ?? this.height,
        width: width ?? this.width,
        underline: underline ?? this.underline,
        align: align ?? this.align,
        fontType: fontType ?? this.fontType,
        italic: italic ?? this.italic,
        upsideDown: upsideDown ?? this.upsideDown,
        rotation: rotation ?? this.rotation,
        inverted: inverted ?? this.inverted,
      );

  T? _getPar<T>(T? par, T? defaultValue, {bool allowNull = true}) {
    if (par != defaultValue) {
      return par ?? defaultValue;
    }
    if (allowNull) return null;
    return defaultValue;
  }

  List<int> getBytes(PrinterType printerType) {
    var bytes = <int>[];

    // Print mode
    if ([fontType, bold, doubleHeight, doubleWidth, italic, underline]
        .nonNulls
        .isNotEmpty) {
      var mode = 0;
      if (fontType == PosFontType.fontB) mode |= 0x01;
      if (bold == true) mode |= 0x08;
      if (doubleHeight == true) mode |= 0x10;
      if (doubleWidth == true) mode |= 0x20;
      if (italic == true) mode |= 0x40;
      if (underline == true) mode |= 0x80;
      bytes += [...commands.printMode.codeUnits, mode];
    }

    // Character size
    if (height != null || width != null) {
      var value = 0;
      if (height != null) value |= height!.heightValue;
      if (width != null) value |= width!.widthValue;
      bytes += [...commands.characterSize.codeUnits, value];
    }

    // Alignment
    if (align != null) {
      bytes += align!.bytes;
    }

    // Upside down
    if (upsideDown != null && printerType != PrinterType.sunmiPos) {
      bytes += [
        ...commands.upsideDown.codeUnits,
        if (upsideDown == true) 1 else 0,
      ];
    }

    // Inverted
    if (inverted != null) {
      bytes += [...commands.inverted.codeUnits, if (inverted == true) 1 else 0];
    }

    // Rotation
    if (rotation != null) {
      bytes += rotation!.bytes;
    }

    return bytes;
  }
}
