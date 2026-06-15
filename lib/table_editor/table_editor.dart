import 'package:flutter/material.dart';

/// Visual table editor for Markdown tables
class TableEditor extends StatefulWidget {
  final Function(String) onTableGenerated;

  const TableEditor({
    super.key,
    required this.onTableGenerated,
  });

  @override
  State<TableEditor> createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  int _rows = 3;
  int _cols = 3;
  List<List<TextEditingController>> _cells = [];

  @override
  void initState() {
    super.initState();
    _initCells();
  }

  void _initCells() {
    _cells = List.generate(
      _rows,
      (_) => List.generate(
        _cols,
        (_) => TextEditingController(),
      ),
    );
  }

  @override
  void dispose() {
    for (final row in _cells) {
      for (final cell in row) {
        cell.dispose();
      }
    }
    super.dispose();
  }

  void _updateGridSize(int newRows, int newCols) {
    final oldCells = _cells;
    
    setState(() {
      _rows = newRows;
      _cols = newCols;
      _initCells();
      
      // Copy old data
      for (var r = 0; r < oldCells.length && r < _rows; r++) {
        for (var c = 0; c < oldCells[r].length && c < _cols; c++) {
          _cells[r][c].text = oldCells[r][c].text;
        }
      }
    });
  }

  String _generateMarkdown() {
    if (_rows == 0 || _cols == 0) return '';
    
    final buffer = StringBuffer();
    
    // Header row
    buffer.write('| ');
    for (var c = 0; c < _cols; c++) {
      buffer.write(_cells[0][c].text.isEmpty ? 'Header ' : _cells[0][c].text);
      buffer.write(' | ');
    }
    buffer.writeln();
    
    // Separator row
    buffer.write('|');
    for (var c = 0; c < _cols; c++) {
      buffer.write(' --- |');
    }
    buffer.writeln();
    
    // Data rows
    for (var r = 1; r < _rows; r++) {
      buffer.write('| ');
      for (var c = 0; c < _cols; c++) {
        buffer.write(_cells[r][c].text);
        buffer.write(' | ');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('行数:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _rows.toString()),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0 && n <= 20) {
                          _updateGridSize(n, _cols);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('列数:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _cols.toString()),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0 && n <= 10) {
                          _updateGridSize(_rows, n);
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('添加行'),
                    onPressed: () {
                      if (_rows < 20) _updateGridSize(_rows + 1, _cols);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.view_column),
                    label: const Text('添加列'),
                    onPressed: () {
                      if (_cols < 10) _updateGridSize(_rows, _cols + 1);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    border: TableBorder.all(color: Theme.of(context).colorScheme.outline),
                    headingRowColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    columns: List.generate(
                      _cols,
                      (c) => DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _cells[0][c],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Header',
                            ),
                          ),
                        ),
                      ),
                    ),
                    rows: List.generate(
                      _rows - 1,
                      (r) => DataRow(
                        cells: List.generate(
                          _cols,
                          (c) => DataCell(
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _cells[r + 1][c],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('插入表格'),
                    onPressed: () {
                      widget.onTableGenerated(_generateMarkdown());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}