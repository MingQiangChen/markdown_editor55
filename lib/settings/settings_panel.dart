import 'package:flutter/material.dart';

import 'settings_base.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onClose,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onSave;
  final VoidCallback onClose;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _update(AppSettings next) {
    setState(() => _settings = next);
    widget.onSave(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text('设置', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                tooltip: '关闭',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFontSizeSection(context),
          const SizedBox(height: 16),
          _buildFontFamilySection(context),
          const SizedBox(height: 16),
          _buildTabSizeSection(context),
          const SizedBox(height: 16),
          _buildViewModeSection(context),
          const SizedBox(height: 16),
          _buildWordWrapSection(context),
          const SizedBox(height: 16),
          _buildAutoSaveSection(context),
        ],
      ),
    );
  }

  Widget _buildFontSizeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体大小: '),
        Slider(
          value: _settings.fontSize,
          min: 10,
          max: 24,
          divisions: 14,
          label: _settings.fontSize.toInt().toString(),
          onChanged: (value) {
            _update(_settings.copyWith(fontSize: value));
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _settings.fontFamily.isEmpty ? null : _settings.fontFamily,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('默认')),
            DropdownMenuItem(value: 'Consolas', child: Text('Consolas')),
            DropdownMenuItem(value: 'Courier New', child: Text('Courier New')),
            DropdownMenuItem(value: 'Monaco', child: Text('Monaco')),
            DropdownMenuItem(
              value: 'Source Code Pro',
              child: Text('Source Code Pro'),
            ),
          ],
          onChanged: (value) {
            _update(_settings.copyWith(fontFamily: value ?? ''));
          },
        ),
      ],
    );
  }

  Widget _buildTabSizeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tab 缩进'),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 2, label: Text('2')),
            ButtonSegment(value: 4, label: Text('4')),
          ],
          selected: {_settings.tabSize},
          onSelectionChanged: (values) {
            _update(_settings.copyWith(tabSize: values.first));
          },
        ),
      ],
    );
  }

  Widget _buildViewModeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('默认视图模式'),
        const SizedBox(height: 8),
        SegmentedButton<EditorViewMode>(
          segments: const [
            ButtonSegment(value: EditorViewMode.editor, label: Text('编辑')),
            ButtonSegment(value: EditorViewMode.split, label: Text('分屏')),
            ButtonSegment(value: EditorViewMode.preview, label: Text('预览')),
          ],
          selected: {_settings.defaultViewMode},
          onSelectionChanged: (values) {
            _update(_settings.copyWith(defaultViewMode: values.first));
          },
        ),
      ],
    );
  }

  Widget _buildWordWrapSection(BuildContext context) {
    return SwitchListTile(
      title: const Text('自动换行'),
      value: _settings.wordWrap,
      onChanged: (value) {
        _update(_settings.copyWith(wordWrap: value));
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAutoSaveSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('自动保存间隔:  ms'),
        Slider(
          value: _settings.autoSaveIntervalMs.toDouble(),
          min: 200,
          max: 2000,
          divisions: 9,
          label: ' ms',
          onChanged: (value) {
            _update(_settings.copyWith(autoSaveIntervalMs: value.toInt()));
          },
        ),
      ],
    );
  }
}
