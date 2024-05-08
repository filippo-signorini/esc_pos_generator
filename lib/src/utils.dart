import 'package:image/image.dart';

String encodeString(String text) => text
  ..replaceAll("\u{2019}", "'")
  ..replaceAll("\u{00B4}", "'")
  ..replaceAll("\u{00BB}", '"')
  ..replaceAll("'\u{00A0}", ' ')
  ..replaceAll("\u{2022}'", '.');

/// Generate multiple bytes for a number: In lower and higher parts, or more parts as needed.
///
/// [value] Input number
/// [bytesNb] The number of bytes to output (1 - 4)
List<int> intLowHigh(int value, int bytesNb) {
  final maxInput = 256 << (bytesNb * 8) - 1;

  if (bytesNb < 1 || bytesNb > 4) {
    throw Exception('Can only output 1-4 bytes');
  }
  if (value < 0 || value > maxInput) {
    throw Exception(
      'Number is too large. Can only output up to $maxInput in $bytesNb bytes',
    );
  }

  final List<int> res = <int>[];
  int buf = value;
  for (int i = 0; i < bytesNb; ++i) {
    res.add(buf % 256);
    buf = buf ~/ 256;
  }
  return res;
}

/// Extracts slices of an image as equal-sized blobs of column-format data.
///
/// [imageSource] Image to extract from
/// [lineHeight] Printed line height in dots
List<List<int>> toColumnFormat(Image imageSource, int lineHeight) {
  final image = Image.from(imageSource);

  // Determine new width: closest integer that is divisible by lineHeight
  final width = (image.width + lineHeight) - (image.width % lineHeight);
  final height = image.height;

  // Create a black bottom layer
  final biggerImage = copyResize(image, width: width, height: height);
  fill(biggerImage, color: ColorRgb8(0, 0, 0));

  // Overlay source image on top of black layer
  compositeImage(biggerImage, image, dstX: 0, dstY: 0);

  int left = 0;
  final List<List<int>> blobs = [];

  while (left < width) {
    // Slice the image vertically
    // The image should be flipped and rotated so that the slices come out as
    // horizontal.
    final slice = copyCrop(
      biggerImage,
      x: left,
      y: 0,
      width: lineHeight,
      height: height,
    );
    grayscale(slice);
    final bytes = slice.convert(numChannels: 1).getBytes();
    blobs.add(bytes);
    left += lineHeight;
  }

  return blobs;
}

/// Merges each 8 values (bits) into one byte
List<int> packBitsIntoBytes(List<int> bytes) {
  const pxPerLine = 8;
  final List<int> res = <int>[];
  const threshold = 127; // set the greyscale -> b/w threshold here
  for (int i = 0; i < bytes.length; i += pxPerLine) {
    int newVal = 0;
    for (int j = 0; j < pxPerLine; j++) {
      newVal = _transformUint32Bool(
        newVal,
        pxPerLine - j,
        bytes[i + j] > threshold,
      );
    }
    res.add(newVal ~/ 2);
  }
  return res;
}

int _transformUint32Bool(int uint32, int shift, bool newValue) {
  return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) |
      ((newValue ? 1 : 0) << shift);
}
