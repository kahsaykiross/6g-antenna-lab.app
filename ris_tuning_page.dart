// lib/pages/ris_tuning_page.dart
// RIS tuning UI with RepaintBoundary snapshot capture for experiments.

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../widgets/array_pattern_widget.dart';
import '../utils/ris.dart';
import '../services/experiment_storage.dart';
import '../models/experiment.dart';

class RISTuningPage extends StatefulWidget {
  const RISTuningPage({Key? key}) : super(key: key);

  @override
  State<RISTuningPage> createState() => _RISTuningPageState();
}

class _RISTuningPageState extends State<RISTuningPage> {
  int numElements = 16;
  int risElements = 32;
  double spacing = 0.5;
  double risGain = 0.8;
  List<double> risPhases = [];
  List<double> pattern = [];

  final GlobalKey _patternKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    risPhases = List<double>.filled(risElements, 0.0);
    _compute();
  }

  Future<void> _compute() async {
    final angles = List<double>.generate(181, (i) => (i - 90) * math.pi / 180.0);
    final p = risCompositePattern(
      numElements: numElements,
      risElements: risElements,
      spacing: spacing,
      sampleAnglesRad: angles,
      risPhases: risPhases,
      risCouplingGain: risGain,
    );
    setState(() => pattern = p);

    final png = await _capturePattern();
    ExperimentStorage().addExperiment(
      Experiment(
        type: 'RIS Tuning',
        timestamp: DateTime.now(),
        parameters: {
          'numElements': numElements,
          'risElements': risElements,
          'spacing': spacing,
          'risGain': risGain,
        },
        pattern: p,
        snapshot: png,
      ),
    );
  }

  Future<Uint8List?> _capturePattern() async {
    try {
      final boundary = _patternKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('RIS capture failed: $e');
      return null;
    }
  }

  void _optimizeRIS() {
    // very simple heuristic: align RIS phases to broadside
    final targetTheta = 0.0;
    final k = 2 * math.pi;
    setState(() {
      for (int m = 0; m < risElements; m++) {
        risPhases[m] = -k * (m + 1) * 0.1 * math.sin(targetTheta);
      }
    });
    _compute();
  }

  void _setPhase(int idx, double val) {
    setState(() => risPhases[idx] = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RIS Tuning'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Text('RIS elements: $risElements • Coupling gain: ${risGain.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(height: 8),
          Row(children: [
            Expanded(child: _intSlider('Array elements', numElements.toDouble(), 4, 64, (v) => setState(() => numElements = v.toInt()))),
            SizedBox(width: 8),
            Expanded(child: _intSlider('RIS elements', risElements.toDouble(), 4, 128, (v) {
              setState(() {
                risElements = v.toInt();
                risPhases = List<double>.filled(risElements, 0.0);
              });
            })),
          ]),
          _doubleSlider('RIS coupling gain', risGain, 0.0, 1.5, (v) => setState(() => risGain = v)),
          SizedBox(height: 8),
          ElevatedButton.icon(icon: Icon(Icons.auto_fix_high), label: Text('Auto-optimize RIS (demo)'), onPressed: _optimizeRIS),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(children: [
                Text('RIS tile phases (first 16 shown)'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(risElements < 16 ? risElements : 16, (i) {
                    return SizedBox(
                      width: 160,
                      child: Column(children: [
                        Text('Tile ${i + 1}'),
                        Slider(value: risPhases[i], min: -math.pi, max: math.pi, onChanged: (v) => _setPhase(i, v), onChangeEnd: (_) => _compute()),
                        Text(risPhases[i].toStringAsFixed(2)),
                      ]),
                    );
                  }),
                ),
              ]),
            ),
          ),
          SizedBox(height: 12),
          RepaintBoundary(
            key: _patternKey,
            child: ArrayPatternWidget(pattern: pattern, width: double.infinity, height: 220),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(icon: Icon(Icons.save), label: Text('Compute & Save Experiment'), onPressed: _compute),
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
      Slider(value: value, min: min, max: max, divisions: 30, label: value.toStringAsFixed(2), onChanged: onChanged),
    ]);
  }
}
