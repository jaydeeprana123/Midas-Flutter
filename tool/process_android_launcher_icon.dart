import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

/// Composites [assets/images/splash_logo.png] onto a white background for
/// the Android launcher icon. Purple logo pixels are kept; near-black
/// background (and anti-aliased dark edges of the plate) become white.
void main() {
  const inputPath = 'assets/images/splash_logo.png';
  const outputPath = 'assets/images/android_launcher_icon.png';

  final bytes = File(inputPath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Unable to decode $inputPath');
  }

  final image = decoded.convert(numChannels: 4);
  stdout.writeln('Source ${image.width}x${image.height}');

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

      // Near-black, low-chroma pixels are the plate behind the mark.
      if (chroma < 28 && luma < 40) {
        image.setPixelRgba(x, y, 255, 255, 255, 255);
      } else {
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  File(outputPath).writeAsBytesSync(img.encodePng(image));
  final corner = image.getPixel(0, 0);
  stdout.writeln(
    'Wrote $outputPath (${image.width}x${image.height}, '
    'corner=rgba(${corner.r.toInt()},${corner.g.toInt()},'
    '${corner.b.toInt()},${corner.a.toInt()}))',
  );
}
