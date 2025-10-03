// lib/utils/calibration.dart
// Calibration simulation that generates per-element amplitude/phase error and suggests corrections.

import 'dart:math' as math;

class CalibrationResult {
  final List<double> measuredAmplitudes;
  final List<double> measuredPhases;
  final List<double> suggestedPhaseCorrection;
  final List<double> suggestedAmplitudeCorrection;

  CalibrationResult({
    required this.measuredAmplitudes,
    required this.measuredPhases,
    required this.suggestedPhaseCorrection,
    required this.suggestedAmplitudeCorrection,
  });
}

CalibrationResult runCalibrationSimulation({
  required int numElements,
  double amplitudeErrorStd = 0.1,
  double phaseErrorStd = 0.2, // radians
}) {
  final rnd = math.Random();
  final amps = List<double>.generate(numElements, (_) => 1.0 + (rnd.nextDouble() * 2 - 1) * amplitudeErrorStd);
  final phases = List<double>.generate(numElements, (_) => (rnd.nextDouble() * 2 - 1) * phaseErrorStd);
  final phaseCorrection = phases.map((p) => -p).toList();
  final ampCorrection = amps.map((a) => 1.0 / (a + 1e-6)).toList();
  return CalibrationResult(
    measuredAmplitudes: amps,
    measuredPhases: phases,
    suggestedPhaseCorrection: phaseCorrection,
    suggestedAmplitudeCorrection: ampCorrection,
  );
}
