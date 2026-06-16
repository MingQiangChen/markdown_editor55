import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_tree_node.dart';

/// 文件树侧边栏面板
class FileTreePanel extends StatefulWidget {
  final void Function(String filePath) onFileSelected;

  const FileTreePanel({
    super.key,
    required this.onFileSelected,
  });

  @override
  State<FileTreePanel> createState() => _FileTreePanelState();
}

class _FileTreePanelState extends State<FileTreePanel> {
  FileTreeNode? _rootNode;
  String? _rootPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: _rootNode == null
                ? _buildEmptyState(context)
                : _buildTreeView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.folder_open, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _rootPath != null 
                  ? _rootPath!.split(Platform.pathSeparator).last 
                  : '文件浏览器',
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, size: 18),
            tooltip: '打开文件夹',
            onPressed: _openFolder,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          if (_rootNode != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: '刷新',
              onPressed: _refreshTree,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: '关闭',
              onPressed: _closeFolder,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            '未打开文件夹',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openFolder,
            icon: const Icon(Icons.folder_open),
            label: const Text('打开文件夹'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _buildTreeNode(_rootNode!, 0),
      ],
    );
  }

  Widget _buildTreeNode(FileTreeNode node, int depth) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (node.isDirectory) {
              setState(() {
                node.isExpanded = !node.isExpanded;
              });
              if (node.isExpanded && node.children.isEmpty) {
                node.loadChildren().then((_) => setState(() {}));
              }
            } else {
              widget.onFileSelected(node.path);
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 8.0 + depth * 16.0,
              right: 8,
              top: 6,
              bottom: 6,
            ),
            child: Row(
              children: [
                if (node.isDirectory)
                  Icon(
                    node.isExpanded ? Icons.folder_open : Icons.folder,
                    size: 18,
                    color: theme.colorScheme.primary,
                  )
                else
                  Icon(
                    node.isMarkdown ? Icons.description : Icons.insert_drive_file,
                    size: 18,
                    color: node.isMarkdown 
                        ? theme.colorScheme.primary 
                        : theme.disabledColor,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: node.isDirectory ? FontWeight.w500 : FontWeight.normal,
                      color: node.isMarkdown && !node.isDirectory
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (node.isExpanded && node.children.isNotEmpty)
          ...node.children.map((child) => _buildTreeNode(child, depth + 1)),
      ],
    );
  }

  Future<void> _openFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择文件夹',
    );
    
    if (path != null) {
      await _loadFolder(path);
    }
  }

  Future<void> _loadFolder(String path) async {
    final node = await FileTreeNode.fromPath(path);
    if (node != null) {
      await node.loadChildren();
      setState(() {
        _rootNode = node;
        _rootPath = path;
        _rootNode!.isExpanded = true;
      });
    }
  }

  Future<void> _refreshTree() async {
    if (_rootPath != null) {
      await _loadFolder(_rootPath!);
    }
  }

  void _closeFolder() {
    setState(() {
      _rootNode = null;
      _rootPath = null;
    });
  }
}