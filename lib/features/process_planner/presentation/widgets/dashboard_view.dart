import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:excel/excel.dart' as excel_pkg hide Border;
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';
import 'workflow_graph/workflow_node.dart';
import 'workflow_graph/horizontal_workflow_graph.dart';

/// Dashboard View - Excel upload, parsing, and graph visualization
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ProcessPlannerController _controller =
      Get.find<ProcessPlannerController>();

  PlatformFile? _selectedFile;
  List<String> _tableHeaders = [];
  List<List<dynamic>> _tableRows = [];
  bool _isReadingFile = false;
  bool _isSubmitting = false;

  Future<void> _browseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _tableHeaders = [];
          _tableRows = [];
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _readFile() async {
    if (_selectedFile == null) {
      _showError('Please select a file first');
      return;
    }
    setState(() => _isReadingFile = true);
    try {
      var bytes = _selectedFile!.bytes;
      if (bytes == null && _selectedFile!.path != null) {
        bytes = await File(_selectedFile!.path!).readAsBytes();
      }
      if (bytes == null) {
        _showError('Could not read file content');
        return;
      }
      try {
        final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
        if (decoder.tables.keys.isEmpty) {
          _showError('No sheets found in the Excel file');
          return;
        }
        final sheetName = decoder.tables.keys.first;
        final sheet = decoder.tables[sheetName];
        final rows = sheet?.rows ?? [];
        if (rows.isEmpty) {
          _showError('No data found in the Excel file');
          setState(() {
            _tableHeaders = [];
            _tableRows = [];
          });
          return;
        }
        setState(() {
          _tableHeaders = rows[0].map((e) => e?.toString() ?? '').toList();
          final headerCount = _tableHeaders.length;
          _tableRows = rows.skip(1).map((row) {
            final list = List<dynamic>.from(row);
            while (list.length < headerCount) list.add('');
            return list.take(headerCount).toList();
          }).toList();
        });
      } catch (e) {
        // Fallback to Excel package
        final excel = excel_pkg.Excel.decodeBytes(bytes);
        if (excel.tables.keys.isEmpty) {
          _showError('No sheets found in the Excel file');
          return;
        }
        final firstSheet = excel.tables.keys.first;
        final table = excel.tables[firstSheet];
        final rows = table?.rows ?? [];
        if (rows.isEmpty) {
          _showError('No data found in the Excel file');
          setState(() {
            _tableHeaders = [];
            _tableRows = [];
          });
          return;
        }
        setState(() {
          _tableHeaders = rows.first
              .map((e) => e?.value?.toString() ?? '')
              .toList();
          final headerCount = _tableHeaders.length;
          _tableRows = rows.skip(1).map((row) {
            final list = row
                .map((cell) => cell?.value?.toString() ?? '')
                .toList();
            while (list.length < headerCount) list.add('');
            return list.take(headerCount).toList();
          }).toList();
        });
      }
      _showSuccess('File read successfully');
    } catch (e) {
      _showError('Unable to read this Excel file');
    } finally {
      setState(() => _isReadingFile = false);
    }
  }

  void _visualizeWorkflow() {
    if (_tableRows.isEmpty) {
      _showError('No data to visualize. Please read a file first.');
      return;
    }

    final List<WorkflowNode> nodes = [];
    final Map<String, int> nodeIndexMap = {};

    // Build nodes from spreadsheet rows
    for (int i = 0; i < _tableRows.length; i++) {
      final row = _tableRows[i];
      final sNo = row.isNotEmpty ? row[0]?.toString().trim() ?? '' : '';
      final name = row.length > 1
          ? row[1]?.toString().trim() ?? 'Unnamed'
          : 'Unnamed';
      if (name.isEmpty && sNo.isEmpty) continue;

      final nodeId = '$sNo|$name';
      final isMerge =
          name.toLowerCase().contains('merge') ||
          name.toLowerCase().contains('final') ||
          name.toLowerCase().contains('goods');

      final node = WorkflowNode(
        id: nodeId,
        displayName: sNo.isNotEmpty ? sNo : name,
        description: name,
        isMerge: isMerge,
        connections: [],
        sequenceIndex: i,
      );

      nodeIndexMap[nodeId] = nodes.length;
      nodeIndexMap[sNo] = nodes.length;
      nodeIndexMap[name] = nodes.length;
      nodes.add(node);
    }

    // Build DAG edges from Next WS column only
    for (int i = 0; i < _tableRows.length; i++) {
      final row = _tableRows[i];
      final sNo = row.isNotEmpty ? row[0]?.toString().trim() ?? '' : '';
      final name = row.length > 1 ? row[1]?.toString().trim() ?? '' : '';
      final currentId = '$sNo|$name';
      if (!nodeIndexMap.containsKey(currentId)) continue;
      final currentIndex = nodeIndexMap[currentId]!;

      bool hasExplicitConnections = false;

      // Next WS = real dependency edges → add to DAG
      final nextWS = row.length > 2 ? row[2]?.toString().trim() ?? '' : '';
      if (nextWS.isNotEmpty) {
        hasExplicitConnections = true;
        for (var target in nextWS.split(',').map((e) => e.trim())) {
          if (nodeIndexMap.containsKey(target)) {
            nodes[currentIndex].connections.add(nodeIndexMap[target]!);
          }
        }
      }

      // Merge Target = semantic metadata only — NOT a DAG edge
      // (col[3] intentionally ignored for edge construction)

      // Fallback: sequential connection if no explicit Next WS
      if (!hasExplicitConnections && i < _tableRows.length - 1) {
        final nextIndex = i + 1;
        if (nextIndex < nodes.length) {
          nodes[currentIndex].connections.add(nextIndex);
        }
      }
    }

    // Ensure all non-terminal nodes have at least one outgoing edge
    for (int i = 0; i < nodes.length - 1; i++) {
      if (nodes[i].connections.isEmpty) {
        nodes[i].connections.add(i + 1);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Process Flow Graph',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRect(child: HorizontalWorkflowGraph(nodes: nodes)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForReview() async {
    if (_tableRows.isEmpty) {
      _showError('No data to submit.');
      return;
    }
    await _controller.fetchProducts();
    if (_controller.products.isEmpty) {
      _showError('Please create a product first.');
      return;
    }

    final productId = _controller.products.first.productId;

    setState(() => _isSubmitting = true);
    try {
      final List<Map<String, dynamic>> steps = [];
      bool hasHeaders = false;
      List<String> headers = [];
      int startRow = 0;

      if (_tableRows.isNotEmpty) {
        final firstRow = _tableRows.first;
        final firstCell = firstRow.isNotEmpty
            ? firstRow[0]?.toString().toLowerCase() ?? ''
            : '';
        if (firstCell.contains('current') ||
            firstCell.contains('step') ||
            firstCell.contains('operation') ||
            firstCell.contains('sequence') ||
            firstCell.contains('ws') ||
            firstCell.contains('work')) {
          hasHeaders = true;
          headers = firstRow
              .map((cell) => cell?.toString().toLowerCase() ?? '')
              .toList();
          startRow = 1;
        }
      }

      for (int i = startRow; i < _tableRows.length; i++) {
        final row = _tableRows[i];
        if (row.isEmpty) continue;

        String name = '';
        String description = '';
        bool isParallel = false;
        bool mergePoint = false;
        int stageGroup = 1;
        const int standardTime = 5;

        for (
          int col = 0;
          col < row.length && col < (hasHeaders ? headers.length : 6);
          col++
        ) {
          final cellValue = row[col]?.toString() ?? '';
          final header = hasHeaders && col < headers.length ? headers[col] : '';

          if (name.isEmpty &&
              (header.contains('current') ||
                  header.contains('ws') ||
                  header.contains('operation') ||
                  header.contains('step') ||
                  header.contains('name') ||
                  (col == 0 && !hasHeaders))) {
            name = cellValue;
          } else if (description.isEmpty &&
              (header.contains('description') ||
                  header.contains('desc') ||
                  header.contains('op description') ||
                  (col == 1 && !hasHeaders))) {
            description = cellValue;
          } else if (header.contains('parallel') ||
              cellValue.toUpperCase().contains('PARALLEL') ||
              (col == 5 && cellValue.contains(','))) {
            isParallel = true;
          } else if (header.contains('merge') ||
              cellValue.toUpperCase().contains('MERGE') ||
              header.contains('notes') &&
                  cellValue.toUpperCase().contains('MERGE')) {
            mergePoint = true;
          }
        }

        if (name.isEmpty && row.isNotEmpty)
          name = row[0]?.toString() ?? 'Unnamed';
        if (description.isEmpty && row.length > 1)
          description = row[1]?.toString() ?? 'No description';

        if (row.length > 5) {
          final machinesCell = row[5]?.toString() ?? '';
          if (machinesCell.toLowerCase().contains('parallel') ||
              machinesCell.contains(',') ||
              machinesCell.toLowerCase().contains('bins')) {
            isParallel = true;
          }
        }
        if (row.length > 4) {
          final notesCell = row[4]?.toString() ?? '';
          if (notesCell.toUpperCase().contains('MERGE')) mergePoint = true;
        }

        stageGroup = mergePoint ? 2 : 1;

        steps.add({
          'name': name.isEmpty ? 'Unnamed Step ${i + 1}' : name,
          'description': description.isEmpty ? 'No description' : description,
          'sequence': i - startRow + 1,
          'is_parallel': isParallel,
          'merge_point': mergePoint,
          'stage_group': stageGroup,
          'standard_time': standardTime,
        });
      }

      if (steps.isEmpty) {
        _showError('No valid steps found in Excel. Please check your data.');
        return;
      }

      final result = await _controller.submitProcessPlanDraft(
        productId: productId,
        steps: steps,
      );

      if (result != null) {
        _showSuccess(
          'Process submitted for review successfully (Routing #${result['routing_id']})',
        );
        setState(() {
          _tableRows.clear();
          _tableHeaders.clear();
          _selectedFile = null;
        });
        await _controller.fetchRoutings();
      } else {
        _showError('Submission failed');
      }
    } catch (e) {
      _showError('Submission failed: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration:
                (dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration)
                    .copyWith(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  color: AppTheme.primary,
                  child: const Text(
                    'Add Process Planner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      inherit: true,
                    ),
                  ),
                ),
                Container(
                  color: dark ? AppTheme.darkSurface : Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // File selection row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _browseFile,
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      dark
                                          ? AppTheme.darkSurfaceVariant
                                          : const Color(0xFFF0F2F5),
                                    ),
                                    foregroundColor: WidgetStatePropertyAll(
                                      dark ? Colors.white : Colors.black87,
                                    ),
                                    elevation: const WidgetStatePropertyAll(0),
                                    padding: const WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: BorderSide(
                                          color: dark
                                              ? Colors.white12
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    textStyle: const WidgetStatePropertyAll(
                                      TextStyle(
                                        inherit: true,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Browse File'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFile?.name ?? 'no file selected',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _isReadingFile ? null : _readFile,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: _isReadingFile
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Read',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Data table
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: dark ? Colors.white12 : Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _tableHeaders.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'No data loaded. Please upload and read an Excel file.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      inherit: true,
                                    ),
                                  ),
                                ),
                              )
                            : Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: dark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        dark
                                            ? Colors.white.withValues(
                                                alpha: 0.05,
                                              )
                                            : const Color(0xFFF8F9FA),
                                      ),
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black87,
                                        inherit: true,
                                      ),
                                      dataTextStyle: TextStyle(
                                        fontSize: 13,
                                        color: dark
                                            ? Colors.white70
                                            : Colors.black87,
                                        inherit: true,
                                      ),
                                      dataRowMinHeight: 48,
                                      dataRowMaxHeight: 100,
                                      columnSpacing: 24,
                                      horizontalMargin: 16,
                                      columns: _tableHeaders
                                          .map(
                                            (h) => DataColumn(
                                              label: SizedBox(
                                                width: 140,
                                                child: Text(
                                                  h,
                                                  style: TextStyle(
                                                    color: dark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      rows: _tableRows.map((row) {
                                        return DataRow(
                                          cells: row
                                              .map(
                                                (cell) => DataCell(
                                                  Container(
                                                    width: 140,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                        ),
                                                    child: Text(
                                                      cell?.toString() ?? '',
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _visualizeWorkflow,
                            style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                Color(0xFF283593),
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              elevation: const WidgetStatePropertyAll(0),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              textStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  inherit: true,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            child: const Text('Visualize'),
                          ),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForReview,
                            style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                Color(0xFF2E7D32),
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              elevation: const WidgetStatePropertyAll(0),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              textStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  inherit: true,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Submit for Review'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _tableHeaders = [];
                                _tableRows = [];
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.grey.shade600,
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              elevation: const WidgetStatePropertyAll(0),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              textStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  inherit: true,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
