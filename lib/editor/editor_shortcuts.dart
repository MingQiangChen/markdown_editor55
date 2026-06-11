import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Defines keyboard shortcuts for the markdown editor.
class EditorShortcuts extends StatelessWidget {
  const EditorShortcuts({
    super.key,
    required this.child,
    required this.onBold,
    required this.onItalic,
    required this.onCode,
    required this.onLink,
    required this.onSave,
    required this.onOpen,
    required this.onNewDocument,
    required this.onFind,
    required this.onTogglePreview,
    required this.onCycleViewMode,
    required this.onToggleWordWrap,
    required this.onNextTab,
    required this.onPreviousTab,
    required this.onCloseTab,
  });

  final Widget child;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onLink;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  final VoidCallback onNewDocument;
  final VoidCallback onFind;
  final VoidCallback onTogglePreview;
  final VoidCallback onCycleViewMode;
  final VoidCallback onToggleWordWrap;
  final VoidCallback onNextTab;
  final VoidCallback onPreviousTab;
  final VoidCallback onCloseTab;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(
            LogicalKeyboardKey.keyB,
            control: true,
          ): const FormatIntent(FormatType.bold),
          const SingleActivator(
            LogicalKeyboardKey.keyI,
            control: true,
          ): const FormatIntent(FormatType.italic),
          const SingleActivator(
            LogicalKeyboardKey.backquote,
            control: true,
          ): const FormatIntent(FormatType.code),
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            control: true,
          ): const FormatIntent(FormatType.link),
          const SingleActivator(
            LogicalKeyboardKey.keyS,
            control: true,
          ): const FileOperationIntent(FileOperationType.save),
          const SingleActivator(
            LogicalKeyboardKey.keyO,
            control: true,
          ): const FileOperationIntent(FileOperationType.open),
          const SingleActivator(
            LogicalKeyboardKey.keyN,
            control: true,
          ): const FileOperationIntent(FileOperationType.newDocument),
          const SingleActivator(LogicalKeyboardKey.keyF, control: true):
              const FindIntent(),
          const SingleActivator(
                LogicalKeyboardKey.keyP,
                control: true,
                shift: true,
              ):
              const TogglePreviewIntent(),
          const SingleActivator(
                LogicalKeyboardKey.keyV,
                control: true,
                shift: true,
              ):
              const CycleViewModeIntent(),
          const SingleActivator(LogicalKeyboardKey.keyZ, alt: true):
              const ToggleWordWrapIntent(),
          const SingleActivator(
            LogicalKeyboardKey.tab,
            control: true,
          ): const TabNavigationIntent(TabDirection.next),
          const SingleActivator(
            LogicalKeyboardKey.tab,
            control: true,
            shift: true,
          ): const TabNavigationIntent(TabDirection.previous),
          const SingleActivator(LogicalKeyboardKey.keyW, control: true):
              const CloseTabIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            FormatIntent: CallbackAction<FormatIntent>(
              onInvoke: (intent) {
                switch (intent.type) {
                  case FormatType.bold:
                    onBold();
                    break;
                  case FormatType.italic:
                    onItalic();
                    break;
                  case FormatType.code:
                    onCode();
                    break;
                  case FormatType.link:
                    onLink();
                    break;
                }
                return null;
              },
            ),
            FileOperationIntent: CallbackAction<FileOperationIntent>(
              onInvoke: (intent) {
                switch (intent.type) {
                  case FileOperationType.save:
                    onSave();
                    break;
                  case FileOperationType.open:
                    onOpen();
                    break;
                  case FileOperationType.newDocument:
                    onNewDocument();
                    break;
                }
                return null;
              },
            ),
            FindIntent: CallbackAction<FindIntent>(
              onInvoke: (intent) {
                onFind();
                return null;
              },
            ),
            TogglePreviewIntent: CallbackAction<TogglePreviewIntent>(
              onInvoke: (intent) {
                onTogglePreview();
                return null;
              },
            ),
            CycleViewModeIntent: CallbackAction<CycleViewModeIntent>(
              onInvoke: (intent) {
                onCycleViewMode();
                return null;
              },
            ),
            ToggleWordWrapIntent: CallbackAction<ToggleWordWrapIntent>(
              onInvoke: (intent) {
                onToggleWordWrap();
                return null;
              },
            ),
            TabNavigationIntent: CallbackAction<TabNavigationIntent>(
              onInvoke: (intent) {
                if (intent.direction == TabDirection.next) {
                  onNextTab();
                } else {
                  onPreviousTab();
                }
                return null;
              },
            ),
            CloseTabIntent: CallbackAction<CloseTabIntent>(
              onInvoke: (intent) {
                onCloseTab();
                return null;
              },
            ),
          },
          child: child,
        ),
      ),
    );
  }
}

class FormatIntent extends Intent {
  const FormatIntent(this.type);
  final FormatType type;
}

enum FormatType { bold, italic, code, link }

class FileOperationIntent extends Intent {
  const FileOperationIntent(this.type);
  final FileOperationType type;
}

enum FileOperationType { save, open, newDocument }

class FindIntent extends Intent {
  const FindIntent();
}

class TogglePreviewIntent extends Intent {
  const TogglePreviewIntent();
}

class CycleViewModeIntent extends Intent {
  const CycleViewModeIntent();
}

class ToggleWordWrapIntent extends Intent {
  const ToggleWordWrapIntent();
}

class TabNavigationIntent extends Intent {
  const TabNavigationIntent(this.direction);
  final TabDirection direction;
}

enum TabDirection { next, previous }

class CloseTabIntent extends Intent {
  const CloseTabIntent();
}
