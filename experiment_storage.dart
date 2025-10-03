// lib/services/experiment_storage.dart
// Singleton storage that keeps experiments in memory and provides export functions:
// - exportToCSV writes experiments.csv to the app documents folder
// - exportPNGs writes any snapshot PNG bytes to separate files

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/experiment.dart';

class ExperimentStorage {
  static final ExperimentStorage _instance = ExperimentStorage._internal();
  factory ExperimentStorage() => _instance;
  ExperimentStorage._internal();

  final List<Experiment> _experiments = [];

  List<Experiment> get experiments => List.unmodifiable(_experiments);

  void addExperiment(Experiment exp) {
    _experiments.add(exp);
  }

  void clear() {
    _experiments.clear();
  }

  /// Export experiments to CSV and return the file path.
  Future<String> exportToCSV() async {
    final rows = <List<dynamic>>[];
    rows.add(['Type', 'Timestamp', 'Parameters', 'Pattern']);

    for (final e in _experiments) {
      rows.add([
        e.type,
        e.timestamp.toIso8601String(),
        e.parameters.toString(),
        e.pattern.join(';'),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/experiments.csv');
    await file.writeAsString(csvData);
    return file.path;
  }

  /// Export PNG snapshots of experiments that have them.
  /// Returns list of saved file paths.
  Future<List<String>> exportPNGs() async {
    final dir = await getApplicationDocumentsDirectory();
    final savedPaths = <String>[];

    for (int i = 0; i < _experiments.length; i++) {
      final exp = _experiments[i];
      final bytes = exp.snapshot;
      if (bytes != null) {
        // sanitize type for filename
        final safeType = exp.type.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
        final file = File('${dir.path}/experiment_${i}_${safeType}.png');
        await file.writeAsBytes(bytes);
        savedPaths.add(file.path);
      }
    }
    return savedPaths;
  }
}
