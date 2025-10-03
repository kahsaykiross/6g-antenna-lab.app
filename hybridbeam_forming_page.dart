// lib/pages/hybrid_beamforming_page.dart
// Advanced page for hybrid beamforming controls. Wraps the pattern widget
// in a RepaintBoundary so we can capture PNG snapshots.

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../widgets/array_pattern_widget.dart';
import '../utils/beamforming.dart';
import '../services/experiment_storage.dart';
import '../models/experiment.dart';

class HybridBeamformingPage extends StatefulWidget {
  const HybridBeamformingPage({Key? key}) : super(key: key);

  @override
  State<HybridBeamformingPage> createState() => _HybridBeamformingPageState();
}

class _HybridBeamformingPageState extends State<HybridBeamformingPage> {
  int numElements = 16;
  int numRF = 4;
  double spacing = 0.5;
  List<double> analogPhases = [];
  List<double> digitalGains = [];
  List<double> pattern = [];

  // Key for capturing the pattern widget image
  final GlobalKey _patternKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    analogPhases = List<double>.filled(numElements, 0.0);
    digitalGains = List<double>.filled(numRF, 1.0);
    _compute();
  }

  // Compute pattern and save an Experiment (with optional PNG snapshot)
  Future<void> _compute() async {
    final angles = List<double>.generate(181, (i) => (i - 90) * math.pi / 180.0);
    final p = hybridBeamformingPattern(
      numElements: numElements,
      numRFChains: numRF,
      spacing: spacing,
      sampleAnglesRad: angles,
      analogPhasePerElement: analogPhases,
      digitalGainPerRF: digitalGains,
    );
    setState(() => pattern = p);

    // Capture pattern snapshot (PNG bytes)
    Uint8List? png = await _capturePattern();

    // Save experiment to storage
    ExperimentStorage().addExperiment(
      Experiment(
        type: 'Hybrid Beamforming',
        timestamp: DateTime.now(),
        parameters: {
          'numElements': numElements,
          'numRF': numRF,
          'spacing': spacing,
          'digitalGains': List.from(digitalGains),
        },
        pattern: p,
        snapshot: png,
      ),
    );
  }

  // Capture widget as PNG using RenderRepaintBoundary
  Future<Uint8List?> _capturePattern() async {
    try {
      final boundary = _patternKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      // capture may fail on some emulators; handle gracefully
      debugPrint('Capture failed: $e');
      return null;
    }
  }

  void _randomizePhases() {
    final rnd = math.Random();
    setState(() {
      analogPhases = List<double>.generate(numElements, (_) => (rnd.nextDouble() * 2 - 1) * math.pi);
    });
    _compute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hybrid Beamforming'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Array: $numElements elements • RF chains: $numRF', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _intSlider('Elements', numElements.toDouble(), 4, 64, (v) {
                  setState(() {
                    numElements = v.toInt();
                    analogPhases = List<double>.filled(numElements, 0.0);
                  });
                })),
                SizedBox(width: 10),
                Expanded(child: _intSlider('RF Chains', numRF.toDouble(), 1, 8, (v) {
                  setState(() {
                    numRF = v.toInt();
                    digitalGains = List<double>.filled(numRF, 1.0);
                  });
                })),
              ],
            ),
            _doubleSlider('Spacing (λ)', spacing, 0.25, 1.0, (v) => setState(() => spacing = v)),
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.shuffle),
              label: Text('Randomize analog phases & compute'),
              onPressed: _randomizePhases,
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text('Digital gains (per RF)'),
                  for (int i = 0; i < digitalGains.length; i++)
                    Row(
                      children: [
                        Text('RF ${i + 1}'),
                        Expanded(
                          child: Slider(
                            value: digitalGains[i],
                            min: 0.1,
                            max: 2.0,
                            onChanged: (v) {
                              setState(() => digitalGains[i] = v);
                            },
                            onChangeEnd: (_) => _compute(),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(digitalGains[i].toStringAsFixed(2)),
                      ],
                    ),
                ]),
              ),
            ),
            SizedBox(height: 12),
            // RepaintBoundary wrapper enables image capture
            RepaintBoundary(
              key: _patternKey,
              child: ArrayPatternWidget(pattern: pattern, width: double.infinity, height: 220),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('Compute & Save Experiment'),
              onPressed: _compute,
            ),
            SizedBox(height: 8),
            Text('Note: This uses a simple hybrid beamforming model for prototyping.'),
          ],
        ),
      ),
    );
  }

  Widget _intSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        label: value.round().toString(),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _doubleSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: ((max - min) * 20).round(),
        label: value.toStringAsFixed(2),
        onChanged: onChanged,
      ),
    ]);
  }
}
