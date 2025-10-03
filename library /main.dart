// lib/main.dart
// App entry point and main navigation shell.

import 'package:flutter/material.dart';
import 'models/proposal.dart';
import 'pages/home_page.dart';
import 'pages/hybrid_beamforming_page.dart';
import 'pages/ris_tuning_page.dart';
import 'pages/calibration_page.dart';
import 'pages/experiments_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Using sample proposal loaded from models
  final Proposal proposal = Proposal.sample();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '6G Antenna Lab',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: MainShell(proposal: proposal),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatelessWidget {
  final Proposal proposal;
  const MainShell({Key? key, required this.proposal}) : super(key: key);

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('6G Antenna Lab'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.indigo),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('6G Lab', style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home / Proposal'),
                onTap: () => _openPage(context, HomePage(proposal: proposal)),
              ),
              ListTile(
                leading: Icon(Icons.settings_input_antenna),
                title: Text('Hybrid Beamforming'),
                onTap: () => _openPage(context, HybridBeamformingPage()),
              ),
              ListTile(
                leading: Icon(Icons.grid_3x3),
                title: Text('RIS Tuning'),
                onTap: () => _openPage(context, RISTuningPage()),
              ),
              ListTile(
                leading: Icon(Icons.build),
                title: Text('Calibration Diagnostics'),
                onTap: () => _openPage(context, CalibrationPage()),
              ),
              ListTile(
                leading: Icon(Icons.science),
                title: Text('Experiments'),
                onTap: () => _openPage(context, ExperimentsPage()),
              ),
            ],
          ),
        ),
      ),
      body: HomePage(proposal: proposal),
    );
  }
}
