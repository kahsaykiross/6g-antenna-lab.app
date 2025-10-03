// lib/pages/calibration_page.dart
// Calibration diagnostics UI with ability to save measurement runs (experiments).

import 'package:flutter/material.dart';
import '../utils/calibration.dart';
import '../services/experiment_storage.dart';
import '../models/experiment.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../widgets/array_pattern_widget.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({Key? key}) : super(key: key);

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  int numElements = 16;
  double ampStd = 0.08;
  double phaseStd = 0.15;
  CalibrationResult? lastResult;

  // Create a visual pattern from calibration measurements for snapshot.
  List<double> _makePatternFromCalibration(CalibrationResult res) {
    // Simple mapping: amplitude * cos(phase) normalized
    final p = <double>[];
    for (int i = 0; i < res.measuredAmplitudes.length; i++) {
      final v = (res.measuredAmplitudes[i] * (math.cos(res.measuredPhases[i]) + 1)) / 2;
      p.add(v);
    }
    final maxVal = p.reduce(math.max);
    return p.map((e) => maxVal <= 0 ? 0.0 : e / maxVal).toList();
  }

  void _runCalibration() {
    final result = runCalibrationSimulation(numElements: numElements, amplitudeErrorStd: ampStd, phaseErrorStd: phaseStd);
    setState(() => lastResult = result);

    final pattern = _makePatternFromCalibration(result);
    // Save experiment (no widget capture used here; snapshot omitted for simplicity)
    ExperimentStorage().addExperiment(
      Experiment(
        type: 'Calibration',
        timestamp: DateTime.now(),
        parameters: {
          'numElements': numElements,
          'ampStd': ampStd,
          'phaseStd': phaseStd,
        },
        pattern: pattern,
        snapshot: null, // could capture a widget snapshot similarly if desired
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _runCalibration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calibration Diagnostics'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Text('Per-element calibration simulation', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(height: 8),
          Row(children: [
            Expanded(child: _intSlider('Elements', numElements.toDouble(), 4, 64, (v) => setState(() => numElements = v.toInt()))),
            SizedBox(width: 8),
            Expanded(child: _doubleSlider('Amp error σ', ampStd, 0.0, 0.3, (v) => setState(() => ampStd = v))),
          ]),
          _doubleSlider('Phase error σ (rad)', phaseStd, 0.0, 0.6, (v) => setState(() => phaseStd = v)),
          SizedBox(height: 8),
          ElevatedButton.icon(icon: Icon(Icons.play_arrow), label: Text('Run Calibration & Save'), onPressed: _runCalibration),
          SizedBox(height: 12),
          if (lastResult != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Measured amplitudes & phases', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: lastResult!.measuredAmplitudes.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            dense: true,
                            title: Text('Element ${i + 1}'),
                            subtitle: Text('Amp: ${lastResult!.measuredAmplitudes[i].toStringAsFixed(3)}  •  Phase: ${lastResult!.measuredPhases[i].toStringAsFixed(3)} rad'),
                            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('ΔAmp ${lastResult!.suggestedAmplitudeCorrection[i].toStringAsFixed(3)}'),
                              Text('ΔPhase ${lastResult!.suggestedPhaseCorrection[i].toStringAsFixed(3)}'),
                            ]),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _intSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), label: value.round().toString(), onChanged: onChanged),
    ]);
  }

  Widget _doubleSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      Slider(value: value, min: min, max: max, divisions: 30, label: value.toStringAsFixed(3), onChanged: onChanged),
    ]);
  }
}
