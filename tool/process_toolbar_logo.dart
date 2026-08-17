import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const inputPath = 'assets/images/toolbar_logo.png';
  const outputPath = 'assets/images/toolbar_logo.png';

  final bytes = File(inputPath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Unable to decode $inputPath');
  }

  // Original asset is RGB-only; alpha is ignored unless we convert first.
  final image = decoded.convert(numChannels: 4);

  // Knock out the black rectangle: dark pixels become transparent, light
  // logo pixels stay white, and midtones keep anti-aliased edges via alpha.
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final luminance =
          (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      image.setPixelRgba(x, y, 255, 255, 255, luminance);
    }
  }

  File(outputPath).writeAsBytesSync(img.encodePng(image));

  final corner = image.getPixel(0, 0);
  stdout.writeln(
    'Processed toolbar logo -> $outputPath '
    '(${image.width}x${image.height}, channels=${image.numChannels}, '
    'corner_a=${corner.a})',
  );
}
