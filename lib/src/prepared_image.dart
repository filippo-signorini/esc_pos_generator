// ignore_for_file: dead_code

import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:esc_pos_generator/src/commands.dart' as commands;
import 'package:esc_pos_generator/src/enums.dart';
import 'package:esc_pos_generator/src/utils.dart';

class PreparedImage {
  final List<int> bytes;

  const PreparedImage(this.bytes);

  static Future<PreparedImage> fromBytes({
    required Uint8List bytes,
    required PrinterType printerType,
  }) async {
    final image = await Isolate.run(() => decodeJpg(bytes));

    return await PreparedImage.fromImage(
      imageSource: image!,
      printerType: printerType,
    );
  }

  static Future<PreparedImage> fromImage({
    required Image imageSource,
    required PrinterType printerType,
  }) async {
    final bytes = await Isolate.run(
      () => _prepareImage(imageSource, printerType),
    );
    return PreparedImage(bytes);
  }

  static List<int> _prepareImage(Image imageSource, PrinterType printerType) {
    List<int> bytes = [];
    final image = Image.from(imageSource);

    const bool highDensityHorizontal = true;
    const bool highDensityVertical = true;

    invert(image);
    flip(image, direction: FlipDirection.horizontal);
    final Image imageRotated = copyRotate(image, angle: 270);

    const int lineHeight = highDensityVertical ? 3 : 1;
    final List<List<int>> blobs = toColumnFormat(imageRotated, lineHeight * 8);

    // Compress according to line density
    // Line height contains 8 or 24 pixels of src image
    // Each blobs[i] contains greyscale bytes [0-255]
    // const int pxPerLine = 24 ~/ lineHeight;
    for (int blobInd = 0; blobInd < blobs.length; blobInd++) {
      blobs[blobInd] = packBitsIntoBytes(blobs[blobInd]);
    }

    final int heightPx = imageRotated.height;
    const int densityByte =
        (highDensityHorizontal ? 1 : 0) + (highDensityVertical ? 32 : 0);

    final List<int> header = List.from(commands.bitImage.codeUnits);
    header.add(densityByte);
    header.addAll(intLowHigh(heightPx, 2));

    // Adjust line spacing (for 16-unit line feeds): ESC 3 0x10 (HEX: 0x1b 0x33 0x10)
    if (printerType == PrinterType.sunmi ||
        printerType == PrinterType.sunmiPos) {
      bytes += [27, 51, 0];
    } else {
      bytes += [27, 51, 16];
    }

    for (int i = 0; i < blobs.length; ++i) {
      bytes += List.from(header)
        ..addAll(blobs[i])
        ..addAll('\n'.codeUnits);
    }
    // Reset line spacing: ESC 2 (HEX: 0x1b 0x32)
    return bytes + [27, 50];
  }
}
