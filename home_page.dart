// lib/pages/home_page.dart
// Simple landing page that shows proposal summary and quick links.

import 'package:flutter/material.dart';
import '../models/proposal.dart';
import 'proposal_page.dart';

class HomePage extends StatelessWidget {
  final Proposal proposal;
  const HomePage({Key? key, required this.proposal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-only page because Drawer is in main shell
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 28),
            Text(proposal.title, style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 8),
            Text('Author: ${proposal.author}', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 12),
            Text(proposal.abstractText),
            SizedBox(height: 18),
            ElevatedButton.icon(
              icon: Icon(Icons.article),
              label: Text('Open Proposal'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProposalPage(proposal: proposal)));
              },
            ),
            SizedBox(height: 18),
            Text('Quick tips', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 8),
            Text('- Use Hybrid Beamforming to prototype analog+digital control.\n- Use RIS Tuning to simulate reflective surface tuning.\n- Use Calibration Diagnostics to generate corrective offsets.\n- Saved experiments can be exported as CSV and PNG.'),
          ],
        ),
      ),
    );
  }
}
