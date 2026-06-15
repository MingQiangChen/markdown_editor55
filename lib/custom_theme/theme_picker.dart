import 'package:flutter/material.dart';
import 'custom_theme.dart';

/// Theme picker dialog for selecting or creating custom themes
class ThemePicker extends StatefulWidget {
  final CustomTheme currentTheme;
  final Function(CustomTheme) onThemeSelected;

  const ThemePicker({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  late CustomTheme _selectedTheme;
  bool _isCreating = false;

  // Editor fields
  late TextEditingController _nameController;
  late Color _primaryColor;
  late Color _backgroundColor;
  late Color _surfaceColor;
  late Color _textColor;
  late Color _accentColor;
  late Color _errorColor;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _nameController = TextEditingController(text: _selectedTheme.name);
    _primaryColor = _selectedTheme.primaryColor;
    _backgroundColor = _selectedTheme.backgroundColor;
    _surfaceColor = _selectedTheme.surfaceColor;
    _textColor = _selectedTheme.textColor;
    _accentColor = _selectedTheme.accentColor;
    _errorColor = _selectedTheme.errorColor;
    _isDark = _selectedTheme.isDark;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickColor(String label, Color currentColor, Function(Color) onPicked) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        title: label,
        initialColor: currentColor,
      ),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  void _saveCustomTheme() {
    final theme = CustomTheme(
      name: _nameController.text.isEmpty ? 'Custom' : _nameController.text,
      primaryColor: _primaryColor,
      backgroundColor: _backgroundColor,
      surfaceColor: _surfaceColor,
      textColor: _textColor,
      accentColor: _accentColor,
      errorColor: _errorColor,
      isDark: _isDark,
    );
    widget.onThemeSelected(theme);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '选择主题',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isCreating = !_isCreating);
                    },
                    child: Text(_isCreating ? '选择预设' : '自定义'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isCreating ? _buildEditor() : _buildThemeGrid(),
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
                    label: const Text('应用'),
                    onPressed: () {
                      widget.onThemeSelected(_selectedTheme);
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

  Widget _buildThemeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: CustomTheme.predefined.length,
      itemBuilder: (context, index) {
        final theme = CustomTheme.predefined[index];
        final isSelected = _selectedTheme.name == theme.name;
        
        return GestureDetector(
          onTap: () {
            setState(() => _selectedTheme = theme);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    theme.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '主题名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('深色模式'),
            value: _isDark,
            onChanged: (v) => setState(() => _isDark = v),
          ),
          const SizedBox(height: 16),
          _buildColorPicker('主色调', _primaryColor, (c) => _primaryColor = c),
          _buildColorPicker('背景色', _backgroundColor, (c) => _backgroundColor = c),
          _buildColorPicker('表面色', _surfaceColor, (c) => _surfaceColor = c),
          _buildColorPicker('文字色', _textColor, (c) => _textColor = c),
          _buildColorPicker('强调色', _accentColor, (c) => _accentColor = c),
          _buildColorPicker('错误色', _errorColor, (c) => _errorColor = c),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('保存主题'),
              onPressed: _saveCustomTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(String label, Color color, Function(Color) onPicked) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _pickColor(label, color, onPicked),
            ),
          ],
        ),
      ),
    );
  }
}

/// Color picker dialog
class _ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;

  const _ColorPickerDialog({
    required this.title,
    required this.initialColor,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _lightness;

  @override
  void initState() {
    super.initState();
    final hsl = HSLColor.fromColor(widget.initialColor);
    _hue = hsl.hue;
    _saturation = hsl.saturation;
    _lightness = hsl.lightness;
  }

  Color get _currentColor {
    return HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            _buildSlider('色相', _hue, 0, 360, (v) => _hue = v),
            _buildSlider('饱和度', _saturation, 0, 1, (v) => _saturation = v),
            _buildSlider('亮度', _lightness, 0, 1, (v) => _lightness = v),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _currentColor),
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (v) => setState(() => onChanged(v)),
        ),
      ],
    );
  }
}