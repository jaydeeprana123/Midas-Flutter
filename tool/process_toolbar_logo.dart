import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const inputPath = 'assets/images/toolbar_logo.png';
  const outputPath = 'assets/images/toolbar_logo.png';

  final bytes = File(inputPath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    throw StateError('Unable to decode $inputPath');
  }

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;

      final isBackground = r < 45 && g < 45 && b < 45;
      if (isBackground) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        image.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
  }

  File(outputPath).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Processed toolbar logo -> $outputPath');
}
