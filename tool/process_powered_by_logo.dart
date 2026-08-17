import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

void main() {
  const inputPath = 'assets/images/powered_by_logo.png';
  const outputPath = 'assets/images/powered_by_logo.png';

  final bytes = File(inputPath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Unable to decode $inputPath');
  }

  final image = decoded.convert(numChannels: 4);
  final corner = image.getPixel(0, 0);
  stdout.writeln(
    'Source ${image.width}x${image.height} corner='
    'rgba(${corner.r.toInt()},${corner.g.toInt()},${corner.b.toInt()},${corner.a.toInt()})',
  );

  // Knock out the black square behind the circular mark. Grey anti-aliased
  // pixels on the outer ring become white with matching alpha. Saturated
  // navy / cyan / red pixels are left unchanged.
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final maxc = max(r, max(g, b));
      final minc = min(r, min(g, b));
      final chroma = maxc - minc;
      final luma = (0.299 * r + 0.587 * g + 0.114 * b).round();

      if (chroma < 22) {
        if (luma < 28) {
          image.setPixelRgba(x, y, 0, 0, 0, 0);
        } else {
          image.setPixelRgba(x, y, 255, 255, 255, luma.clamp(0, 255));
        }
      }
    }
  }

  File(outputPath).writeAsBytesSync(img.encodePng(image));

  final outCorner = image.getPixel(0, 0);
  stdout.writeln(
    'Processed powered-by logo -> $outputPath '
    '(${image.width}x${image.height}, corner_a=${outCorner.a.toInt()})',
  );
}
