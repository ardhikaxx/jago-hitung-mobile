import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final dir = Directory('assets/sounds');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // click.wav - short tick (50ms, 800Hz)
  _generateWav('${dir.path}/click.wav', 0.05, 800, 'blip');

  // correct.wav - ascending happy tone (300ms)
  _generateWav('${dir.path}/correct.wav', 0.3, 523, 'ascending');

  // wrong.wav - descending buzz (300ms)
  _generateWav('${dir.path}/wrong.wav', 0.3, 200, 'descending');

  print('Sound files generated in ${dir.path}');
}

void _generateWav(String path, double duration, double freq, String type) {
  final sampleRate = 44100;
  final numSamples = (sampleRate * duration).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double sample;

    switch (type) {
      case 'blip':
        final envelope = (1.0 - t / duration).clamp(0.0, 1.0);
        sample = sin(2 * pi * freq * t) * envelope * 0.5;
        break;
      case 'ascending':
        final freqNow = freq + (freq * 2 * t / duration);
        final envelope = sin(pi * t / duration).clamp(0.0, 1.0);
        sample = (sin(2 * pi * freqNow * t) * 0.4 +
                   sin(2 * pi * freqNow * 1.5 * t) * 0.2) * envelope;
        break;
      case 'descending':
        final freqNow = freq * 3 - (freq * 2.5 * t / duration);
        final envelope = sin(pi * t / duration).clamp(0.0, 1.0);
        sample = (sin(2 * pi * freqNow * t) * 0.3 +
                   sin(2 * pi * freqNow * 0.5 * t) * 0.2) * envelope;
        break;
      default:
        sample = 0;
    }

    samples[i] = (sample * 32767).round().clamp(-32768, 32767);
  }

  final bytes = _wavBytes(samples, sampleRate);
  File(path).writeAsBytesSync(bytes);
  print('  Created: $path (${bytes.length} bytes)');
}

List<int> _wavBytes(Int16List samples, int sampleRate) {
  final dataSize = samples.length * 2; // 16-bit = 2 bytes per sample
  final buffer = BytesBuilder();

  // RIFF header
  buffer.add(_toAscii('RIFF'));
  buffer.add(_toLE32(36 + dataSize));
  buffer.add(_toAscii('WAVE'));

  // fmt chunk
  buffer.add(_toAscii('fmt '));
  buffer.add(_toLE32(16)); // chunk size
  buffer.add(_toLE16(1));  // PCM format
  buffer.add(_toLE16(1));  // mono
  buffer.add(_toLE32(sampleRate));
  buffer.add(_toLE32(sampleRate * 2)); // byte rate
  buffer.add(_toLE16(2));  // block align
  buffer.add(_toLE16(16)); // bits per sample

  // data chunk
  buffer.add(_toAscii('data'));
  buffer.add(_toLE32(dataSize));
  buffer.add(samples.buffer.asUint8List());

  return buffer.takeBytes();
}

List<int> _toAscii(String s) => s.codeUnits;
List<int> _toLE16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _toLE32(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
