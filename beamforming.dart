// lib/utils/beamforming.dart
// Simple hybrid beamforming demo stub. This is a lightweight functional model
// showing how analog phases + digital gains combine into an effective pattern.
// Replace with your optimization/backend code for production.

import 'dart:math' as math;

List<double> hybridBeamformingPattern({
  required int numElements,
  required int numRFChains,
  required double spacing,
  required List<double> sampleAnglesRad,
  required List<double> analogPhasePerElement, // radians, length = numElements
  required List<double> digitalGainPerRF, // length = numRFChains
}) {
  // Combine analog phase and digital gain in a simple way (demo only)
  final combinedPhases = List<double>.filled(numElements, 0.0);
  for (int n = 0; n < numElements; n++) {
    final rf = n % numRFChains;
    // note: using log(gain) to incorporate magnitude in phase-like term (toy model)
    combinedPhases[n] = analogPhasePerElement[n] + math.log(digitalGainPerRF[rf] + 1e-9);
  }

  final k = 2 * math.pi;
  final pattern = <double>[];
  for (final theta in sampleAnglesRad) {
    double re = 0.0, im = 0.0;
    for (int n = 0; n < numElements; n++) {
      final phase = k * n * spacing * math.sin(theta) + combinedPhases[n];
      re += math.cos(phase);
      im += math.sin(phase);
    }
    pattern.add(math.sqrt(re * re + im * im));
  }
  final maxVal = pattern.reduce(math.max);
  return pattern.map((e) => maxVal <= 0 ? 0.0 : e / maxVal).toList();
}
