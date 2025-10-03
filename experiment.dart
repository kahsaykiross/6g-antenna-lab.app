// lib/models/experiment.dart
// Model for storing saved experiments. Contains optional PNG snapshot bytes.

import 'dart:typed_data';

class Experiment {
  final String type; // e.g., "Hybrid Beamforming"
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final List<double> pattern; // pattern samples
  final Uint8List? snapshot; // optional PNG bytes (thumbnail / full image)

  Experiment({
    required this.type,
    required this.timestamp,
    required this.parameters,
    required this.pattern,
    this.snapshot,
  });

  // Lightweight JSON (snapshot not included in JSON export)
  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'parameters': parameters,
        'pattern': pattern,
      };

  String toPrettyString() {
    return '$type (${timestamp.toLocal()})\nParams: $parameters\nPattern length: ${pattern.length}';
  }
}
