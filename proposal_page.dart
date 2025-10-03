// lib/pages/proposal_page.dart
// Displays the proposal sections and a small array simulator stub.

import 'package:flutter/material.dart';
import '../models/proposal.dart';
import '../utils/dsp_math.dart';
import '../widgets/array_pattern_widget.dart';
import 'dart:math' as math;

class ProposalPage extends StatefulWidget {
  final Proposal proposal;
  const ProposalPage({Key? key, required this.proposal}) : super(key: key);

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  int numElements = 8;
  double spacing = 0.5;
  double steeringDeg = 0.0;
  List<double> pattern = [];

  void _computePattern() {
    final angles = List<double>.generate(181, (i) => (i - 90) * math.pi / 180.0); // -90..+90 deg
    final pat = ulaArrayPattern(
      numElements: numElements,
      elementSpacingWavelength: spacing,
      steeringAngleRad: steeringDeg * math.pi / 180,
      sampleAnglesRad: angles,
    );
    setState(() => pattern = pat);
  }

  @override
  void initState() {
    super.initState();
    _computePattern();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proposal'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.proposal.title, style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),
          Text('Keywords: ${widget.proposal.keywords.join(', ')}'),
          SizedBox(height: 12),
          ...widget.proposal.sections.map((s) => ExpansionTile(title: Text(s.title), children: [Padding(padding: EdgeInsets.all(12), child: Text(s.content))])),
          SizedBox(height: 12),
          Text('Array Demo', style: Theme.of(context).textTheme.subtitle1),
          Slider(
            value: numElements.toDouble(),
            min: 2,
            max: 64,
            divisions: 62,
            label: '$numElements',
            onChanged: (v) => setState(() => numElements = v.toInt()),
            onChangeEnd: (_) => _computePattern(),
          ),
          Text('Steering ${steeringDeg.toStringAsFixed(1)}°'),
          Slider(
            value: steeringDeg,
            min: -60,
            max: 60,
            divisions: 120,
            label: steeringDeg.toStringAsFixed(1),
            onChanged: (v) => setState(() => steeringDeg = v),
            onChangeEnd: (_) => _computePattern(),
          ),
          SizedBox(height: 12),
          ArrayPatternWidget(pattern: pattern, width: double.infinity, height: 200),
        ]),
      ),
    );
  }
}
