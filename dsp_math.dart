// lib/utils/dsp_math.dart
// Basic DSP utilities used by visualization: ULA narrowband pattern generator.

import 'dart:math' as math;

/// Uniform linear array (ULA) normalized pattern (0..1)
List<double> ulaArrayPattern({
  required int numElements,
  required double elementSpacingWavelength, // spacing in wavelengths
  required double steeringAngleRad, // steering angle in radians
  required List<double> sampleAnglesRad,
}) {
  final k = 2 * math.pi;
  final pattern = <double>[];
  for (final theta in sampleAnglesRad) {
    final delta = math.sin(theta) - math.sin(steeringAngleRad);
    double re = 0.0, im = 0.0;
    for (int n = 0; n < numElements; n++) {
      final phase = k * n * elementSpacingWavelength * delta;
      re += math.cos(phase);
      im += math.sin(phase);
    }
    pattern.add(math.sqrt(re * re + im * im));
  }
  final maxVal = pattern.reduce(math.max);
  if (maxVal <= 0) return pattern.map((e) => 0.0).toList();
  return pattern.map((e) => e / maxVal).toList();
}
