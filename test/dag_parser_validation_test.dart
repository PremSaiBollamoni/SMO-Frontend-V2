import 'package:flutter_test/flutter_test.dart';

// Terminal sentinel values (case-insensitive)
// These are valid terminators, not unknown targets
const Set<String> _terminalSentinels = {
  'END',
  'STOP',
  'FINISH',
  'COMPLETE',
  'TERMINAL',
  'N/A',
  '-',
};

bool _isTerminalSentinel(String value) {
  return _terminalSentinels.contains(value.toUpperCase());
}

// Helper functions for validation
String? _detectCycle(Map<String, List<String>> adjacencyList) {
  final Set<String> visited = {};
  final Set<String> recursionStack = {};

  String? dfs(String node, List<String> path) {
    visited.add(node);
    recursionStack.add(node);
    path.add(node);

    for (final neighbor in adjacencyList[node] ?? []) {
      if (!visited.contains(neighbor)) {
        final result = dfs(neighbor, List.from(path));
        if (result != null) return result;
      } else if (recursionStack.contains(neighbor)) {
        // Cycle detected
        final cycleStart = path.indexOf(neighbor);
        final cycle = path.sublist(cycleStart) + [neighbor];
        return 'Cyclic dependency detected: ${cycle.join(' → ')}';
      }
    }

    recursionStack.remove(node);
    return null;
  }

  for (final node in adjacencyList.keys) {
    if (!visited.contains(node)) {
      final result = dfs(node, []);
      if (result != null) return result;
    }
  }

  return null;
}

String? _detectDisconnectedComponents(
    Map<String, List<String>> adjacencyList, Set<String> allNodes) {
  final Set<String> visited = {};

  void bfs(String start) {
    final queue = [start];
    visited.add(start);

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      for (final neighbor in adjacencyList[node] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }
  }

  int componentCount = 0;
  for (final node in allNodes) {
    if (!visited.contains(node)) {
      bfs(node);
      componentCount++;
    }
  }

  if (componentCount > 1) {
    return 'Warning: Graph has $componentCount disconnected components. This may indicate missing dependencies.';
  }

  return null;
}

/// Detects spreadsheet type based on headers
String _detectSpreadsheetType(List<String> tableHeaders) {
  if (tableHeaders.isEmpty) return 'sequential';

  final headerLower = tableHeaders.map((h) => h.toLowerCase()).toList();

  // Check for DAG mode indicators
  bool hasCurrentWS = headerLower.any((h) => h.contains('current'));
  bool hasNextWS = headerLower.any((h) => h.contains('next'));

  if (hasCurrentWS && hasNextWS) {
    return 'dag';
  }

  // Check for sequential mode indicators
  bool hasSNo = headerLower.any((h) => 
      h.contains('s.no') || h.contains('s no') || h.contains('sequence') || h.contains('order'));
  bool hasProcessName = headerLower.any((h) => 
      h.contains('process') || h.contains('operation') || h.contains('step') || h.contains('activity'));

  if (hasSNo && hasProcessName && !hasNextWS) {
    return 'sequential';
  }

  return 'sequential';
}

String? validateSpreadsheet(
  List<List<dynamic>> tableRows,
  List<String> tableHeaders,
  int currentWSCol,
  int nextWSCol,
) {
  final spreadsheetType = _detectSpreadsheetType(tableHeaders);

  // Skip DAG validation for sequential mode
  if (spreadsheetType == 'sequential') {
    return null;
  }
  // Extract all Current WS codes
  final Set<String> currentWSSet = {};
  final List<String> currentWSList = [];

  for (final row in tableRows) {
    final currentWS = currentWSCol < row.length
        ? row[currentWSCol]?.toString().trim() ?? ''
        : '';

    if (currentWS.isEmpty) continue;

    // Check for duplicates
    if (currentWSSet.contains(currentWS)) {
      return 'Duplicate Current WS found: "$currentWS". Each operation must be unique.';
    }

    currentWSSet.add(currentWS);
    currentWSList.add(currentWS);
  }

  if (currentWSSet.isEmpty) {
    return 'No valid operations found in spreadsheet.';
  }

  // Validate all Next WS targets exist
  for (int i = 0; i < tableRows.length; i++) {
    final row = tableRows[i];
    final currentWS = currentWSCol < row.length
        ? row[currentWSCol]?.toString().trim() ?? ''
        : '';

    if (currentWS.isEmpty) continue;

    final nextWSRaw = nextWSCol < row.length
        ? row[nextWSCol]?.toString().trim() ?? ''
        : '';

    if (nextWSRaw.isNotEmpty) {
      final targets = nextWSRaw.split(',').map((t) => t.trim()).toList();
      for (final target in targets) {
        if (target.isNotEmpty && 
            !currentWSSet.contains(target) && 
            !_isTerminalSentinel(target)) {
          return 'Unknown Next WS target: "$target" (referenced by "$currentWS"). Target does not exist in Current WS column.';
        }
      }
    }
  }

  // Build adjacency list for cycle detection
  final Map<String, List<String>> adjacencyList = {};
  for (final ws in currentWSSet) {
    adjacencyList[ws] = [];
  }

  for (final row in tableRows) {
    final currentWS = currentWSCol < row.length
        ? row[currentWSCol]?.toString().trim() ?? ''
        : '';

    if (currentWS.isEmpty) continue;

    final nextWSRaw = nextWSCol < row.length
        ? row[nextWSCol]?.toString().trim() ?? ''
        : '';

    if (nextWSRaw.isNotEmpty) {
      final targets = nextWSRaw.split(',').map((t) => t.trim()).toList();
      for (final target in targets) {
        if (target.isNotEmpty) {
          adjacencyList[currentWS]!.add(target);
        }
      }
    }
  }

  // Cycle detection using DFS
  final String? cycleError = _detectCycle(adjacencyList);
  if (cycleError != null) {
    return cycleError;
  }

  // Disconnected component detection
  final String? disconnectError =
      _detectDisconnectedComponents(adjacencyList, currentWSSet);
  if (disconnectError != null) {
    return disconnectError;
  }

  return null; // Valid
}

void main() {
  group('DAG Parser Validation Tests', () {

    // ========== NEGATIVE TESTS (MUST REJECT) ==========

    test('Invalid Test 1 - Cycle Detection (A->B->C->A)', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'C'],
        ['C', 'A'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Cyclic dependency detected'));
      expect(error, contains('A → B → C → A'));
    });

    test('Invalid Test 2 - Duplicate Current WS', () {
      final tableRows = [
        ['CUTTING', 'SPREADING'],
        ['SPREADING', 'INSPECTION'],
        ['CUTTING', 'INSPECTION'], // Duplicate CUTTING
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Duplicate Current WS found'));
      expect(error, contains('CUTTING'));
    });

    test('Invalid Test 3 - Unknown Next WS Target', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'Z_UNKNOWN'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Unknown Next WS target'));
      expect(error, contains('Z_UNKNOWN'));
      expect(error, contains('does not exist in Current WS column'));
    });

    test('Invalid Test 4 - Disconnected Graph (A->B, X->Y)', () {
      final tableRows = [
        ['A', 'B'],
        ['B', ''],
        ['X', 'Y'],
        ['Y', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('disconnected components'));
      expect(error, contains('2')); // 2 components
    });

    // ========== POSITIVE REGRESSION TESTS (MUST PASS) ==========

    test('Positive Test 1 - Linear Process (Jeans 13 ops)', () {
      final tableRows = [
        ['Cutting', 'Spreading'],
        ['Spreading', 'Inspection'],
        ['Inspection', 'Packing'],
        ['Packing', 'Finishing'],
        ['Finishing', 'QC'],
        ['QC', 'Labeling'],
        ['Labeling', 'Boxing'],
        ['Boxing', 'Shipping'],
        ['Shipping', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Positive Test 2 - Branching Process (4-way parallel)', () {
      final tableRows = [
        ['Cutting', 'Collar, Body, Sleeve, Pocket'],
        ['Collar', 'Merge_Collar'],
        ['Body', 'Merge_Body'],
        ['Sleeve', 'Merge_Sleeve'],
        ['Pocket', 'Merge_Pocket'],
        ['Merge_Collar', 'Final_Assembly'],
        ['Merge_Body', 'Final_Assembly'],
        ['Merge_Sleeve', 'Final_Assembly'],
        ['Merge_Pocket', 'Final_Assembly'],
        ['Final_Assembly', 'Packing'],
        ['Packing', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Positive Test 3 - Complex Mixed Process', () {
      final tableRows = [
        ['Step1', 'Step2'],
        ['Step2', 'Step3, Step4'],
        ['Step3', 'Step5'],
        ['Step4', 'Step5'],
        ['Step5', 'Step6'],
        ['Step6', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Positive Test 4 - Different Column Order', () {
      final tableRows = [
        ['Machine1', 'Op1', 'Op2'],
        ['Machine2', 'Op2', 'Op3'],
        ['Machine3', 'Op3', ''],
      ];
      final tableHeaders = ['Machine', 'Current WS', 'Next WS'];

      // Current WS in column 1, Next WS in column 2
      final error = validateSpreadsheet(tableRows, tableHeaders, 1, 2);

      expect(error, isNull);
    });

    test('Positive Test 5 - Single Operation', () {
      final tableRows = [
        ['OnlyOp', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Positive Test 6 - Empty Next WS (Sequential Fallback)', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'C'],
        ['C', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Positive Test 7 - Nested Reconvergence', () {
      final tableRows = [
        ['Start', 'A, B'],
        ['A', 'Merge1'],
        ['B', 'Merge1'],
        ['Merge1', 'C, D'],
        ['C', 'Merge2'],
        ['D', 'Merge2'],
        ['Merge2', 'End'],
        ['End', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    // ========== EDGE CASE TESTS ==========

    test('Edge Case 1 - Self-Loop (A->A)', () {
      final tableRows = [
        ['A', 'A'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Cyclic dependency detected'));
    });

    test('Edge Case 2 - Multiple Cycles', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'A'],
        ['C', 'D'],
        ['D', 'C'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Cyclic dependency detected'));
    });

    test('Edge Case 3 - Comma-Separated with Unknown Target', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'C'],
        ['C', 'UNKNOWN, D'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Unknown Next WS target'));
      expect(error, contains('UNKNOWN'));
    });

    test('Edge Case 4 - Empty Rows Ignored', () {
      final tableRows = [
        ['A', 'B'],
        ['', ''],
        ['B', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Edge Case 5 - Whitespace Trimming', () {
      final tableRows = [
        ['  A  ', '  B  '],
        ['  B  ', ''],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    // ========== TERMINAL SENTINEL TESTS ==========

    test('Terminal Sentinel 1 - END', () {
      final tableRows = [
        ['FINISHED_GOODS', 'END'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 2 - STOP', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'STOP'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 3 - FINISH', () {
      final tableRows = [
        ['A', 'FINISH'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 4 - COMPLETE', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'COMPLETE'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 5 - TERMINAL', () {
      final tableRows = [
        ['A', 'TERMINAL'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 6 - N/A', () {
      final tableRows = [
        ['A', 'N/A'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 7 - Dash (-)', () {
      final tableRows = [
        ['A', '-'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 8 - Case Insensitive (end)', () {
      final tableRows = [
        ['A', 'end'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 9 - Mixed Case (FiNiSh)', () {
      final tableRows = [
        ['A', 'FiNiSh'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('Terminal Sentinel 10 - Multiple Sentinels', () {
      final tableRows = [
        ['A', 'B, END'],
        ['B', 'STOP'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNull);
    });

    test('True Unknown Target Still Rejected', () {
      final tableRows = [
        ['A', 'B'],
        ['B', 'XYZ_UNKNOWN'],
      ];
      final tableHeaders = ['Current WS', 'Next WS'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 0, 1);

      expect(error, isNotNull);
      expect(error, contains('Unknown Next WS target'));
      expect(error, contains('XYZ_UNKNOWN'));
    });

    // ========== SEQUENTIAL MODE TESTS ==========

    test('Sequential Mode 1 - Jeans Manufacturing (13 ops)', () {
      final tableRows = [
        ['1', 'Fabric Inspection', 'Inspection Table', '0.5'],
        ['2', 'Fabric Spreading', 'Spreading Table', '0.6'],
        ['3', 'Cutting', 'Cutting Machine', '1.2'],
        ['4', 'Front Pocket Attach', 'Lockstitch', '0.8'],
        ['5', 'Back Pocket Attach', 'Lockstitch', '0.9'],
        ['6', 'Fly Zipper Attach', 'Lockstitch', '1.0'],
        ['7', 'Join Front Rise', 'Overlock', '0.7'],
        ['8', 'Join Back Rise', 'Overlock', '0.7'],
        ['9', 'Side Seam Join', 'Overlock', '1.0'],
        ['10', 'Inseam Stitch', 'Overlock', '1.0'],
        ['11', 'Waistband Attach', 'Lockstitch', '1.2'],
        ['12', 'Bottom Hem', 'Lockstitch', '0.8'],
        ['13', 'Finishing & Packing', 'Manual', '0.6'],
      ];
      final tableHeaders = ['S.No', 'Process Name', 'Machine Type', 'SMV'];

      // Sequential mode should not run DAG validation
      // This test verifies no validation errors for sequential format
      final error = validateSpreadsheet(tableRows, tableHeaders, 1, 2);

      expect(error, isNull);
    });

    test('Sequential Mode 2 - No Next WS Column', () {
      final tableRows = [
        ['1', 'Operation A', 'Machine1'],
        ['2', 'Operation B', 'Machine2'],
        ['3', 'Operation C', 'Machine3'],
      ];
      final tableHeaders = ['S.No', 'Process Name', 'Machine Type'];

      final error = validateSpreadsheet(tableRows, tableHeaders, 1, 2);

      expect(error, isNull);
    });

    test('Sequential Mode 3 - Machine Type Not Treated as Target', () {
      final tableRows = [
        ['1', 'Cutting', 'Cutter'],
        ['2', 'Spreading', 'Spreader'],
      ];
      final tableHeaders = ['Sequence', 'Operation', 'Equipment'];

      // Machine Type column should not be validated as Next WS
      final error = validateSpreadsheet(tableRows, tableHeaders, 1, 2);

      expect(error, isNull);
    });
  });
}
