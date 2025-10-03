// lib/utils/ris.dart
// Simplified RIS composite pattern generator. Combines main array and RIS re-radiation.

import 'dart:math' as math;

List<double> risCompositePattern({
  required int numElements,
  required int risElements,
  required double spacing,
  required List<double> sampleAnglesRad,
  required List<double> risPhases, // length risElements
  required double risCouplingGain,
}) {
  final k = 2 * math.pi;

  // main array pattern (no steering)
  final mainPattern = <double>[];
  for (final theta in sampleAnglesRad) {
    double re = 0.0, im = 0.0;
    for (int n = 0; n < numElements; n++) {
      final phase = k * n * spacing * math.sin(theta);
      re += math.cos(phase);
      im += math.sin(phase);
    }
    mainPattern.add(math.sqrt(re * re + im * im));
  }

  // RIS pattern
  final risPattern = <double>[];
  for (final theta in sampleAnglesRad) {
    double re = 0.0, im = 0.0;
    for (int m = 0; m < risElements; m++) {
      final phase = risPhases[m % risPhases.length] + k * (m + 1) * 0.1 * math.sin(theta);
      re += math.cos(phase);
      im += math.sin(phase);
    }
    risPattern.add(math.sqrt(re * re + im * im) * risCouplingGain);
  }

  // Combine and normalize
  final combined = <double>[];
  for (int i = 0; i < mainPattern.length; i++) {
    combined.add(mainPattern[i] + risPattern[i]);
  }
  final maxVal = combined.reduce(math.max);
  return combined.map((e) => maxVal <= 0 ? 0.0 : e / maxVal).toList();
}
