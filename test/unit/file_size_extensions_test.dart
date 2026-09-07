import 'package:smart_storage_compressor/core/extensions/file_size_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('FileSizeExtensions Tests', () {
    test('Formats bytes correctly into B, KB, MB, GB', () {
      expect(0.formatBytes(), equals('0 B'));
      expect(500.formatBytes(), equals('500 B'));
      expect((1024).formatBytes(), equals('1.0 KB'));
      expect((1024 * 1024 * 15).formatBytes(), equals('15.0 MB'));
      expect((1024 * 1024 * 1024 * 2).formatBytes(), equals('2.0 GB'));
    });

    test('Calculates saved percentage correctly (PRD example: 320 MB -> 28 MB is ~91%)', () {
      const originalBytes = 320 * 1024 * 1024;
      const compressedBytes = 28 * 1024 * 1024;

      final savedPercent = originalBytes.calculateSavedPercentage(compressedBytes);
      expect(savedPercent, closeTo(91.25, 0.01));
    });

    test('Returns 0% savings when compressed size is greater or equal', () {
      const originalBytes = 100 * 1024 * 1024;
      const bloatedBytes = 120 * 1024 * 1024;

      expect(originalBytes.calculateSavedPercentage(bloatedBytes), equals(0.0));
      expect(originalBytes.calculateSavedPercentage(originalBytes), equals(0.0));
    });
  });
}
