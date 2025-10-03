// lib/pages/experiments_page.dart
// View saved experiments, export CSV and PNGs to the Documents folder,
// and clear the experiment list.

import 'package:flutter/material.dart';
import '../services/experiment_storage.dart';
import '../models/experiment.dart';

class ExperimentsPage extends StatefulWidget {
  const ExperimentsPage({Key? key}) : super(key: key);

  @override
  State<ExperimentsPage> createState() => _ExperimentsPageState();
}

class _ExperimentsPageState extends State<ExperimentsPage> {
  final storage = ExperimentStorage();

  Future<void> _exportCSV() async {
    final path = await storage.exportToCSV();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported CSV to: $path')));
  }

  Future<void> _exportPNGs() async {
    final paths = await storage.exportPNGs();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported ${paths.length} PNG(s) to Documents folder')));
  }

  void _clear() {
    setState(() {
      storage.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final experiments = storage.experiments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Experiments'),
        actions: [
          IconButton(icon: Icon(Icons.save_alt), onPressed: _exportCSV),
          IconButton(icon: Icon(Icons.image), onPressed: _exportPNGs),
          IconButton(icon: Icon(Icons.delete), onPressed: () {
            _clear();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cleared experiments')));
          }),
        ],
      ),
      body: experiments.isEmpty
          ? Center(child: Text('No experiments saved yet.'))
          : ListView.builder(
              itemCount: experiments.length,
              itemBuilder: (context, i) {
                final e = experiments[i];
                return Card(
                  child: ListTile(
                    title: Text(e.type),
                    subtitle: Text(e.toPrettyString()),
                    trailing: e.snapshot != null ? Image.memory(e.snapshot!, width: 60, height: 40, fit: BoxFit.cover) : null,
                  ),
                );
              },
            ),
    );
  }
}
