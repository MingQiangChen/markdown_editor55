import 'package:flutter/material.dart';

/// Task item model
class TaskItem {
  final String text;
  bool isCompleted;

  TaskItem({
    required this.text,
    this.isCompleted = false,
  });
}

/// Visual task list editor with drag-and-drop support
class TaskListEditor extends StatefulWidget {
  final Function(String) onTasksGenerated;

  const TaskListEditor({
    super.key,
    required this.onTasksGenerated,
  });

  @override
  State<TaskListEditor> createState() => _TaskListEditorState();
}

class _TaskListEditorState extends State<TaskListEditor> {
  final List<TaskItem> _tasks = [];
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    
    setState(() {
      _tasks.add(TaskItem(text: _taskController.text.trim()));
      _taskController.clear();
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
  }

  String _generateMarkdown() {
    final buffer = StringBuffer();
    for (final task in _tasks) {
      final checkbox = task.isCompleted ? '[x]' : '[ ]';
      buffer.writeln('- $checkbox ${task.text}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: '添加新任务',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('添加'),
                    onPressed: _addTask,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text('暂无任务，请添加新任务'),
                    )
                  : ReorderableListView.builder(
                      itemCount: _tasks.length,
                      onReorder: _reorderTasks,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          key: ValueKey(index),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => _toggleTask(index),
                            ),
                            title: Text(
                              task.text,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? Theme.of(context).disabledColor
                                    : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeTask(index),
                            ),
                          ),
                        );
                      },
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
                    label: const Text('插入任务列表'),
                    onPressed: () {
                      widget.onTasksGenerated(_generateMarkdown());
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