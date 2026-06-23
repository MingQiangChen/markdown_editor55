import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Desktop implementation using desktop_drop package.
class PlatformDropTarget extends StatelessWidget {
  const PlatformDropTarget({
    super.key,
    required this.child,
    this.onDragDone,
    this.onDragEntered,
    this.onDragExited,
  });

  final Widget child;
  final void Function(dynamic details)? onDragDone;
  final void Function(dynamic details)? onDragEntered;
  final void Function(dynamic details)? onDragExited;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) => onDragDone?.call(details),
      onDragEntered: (details) => onDragEntered?.call(details),
      onDragExited: (details) => onDragExited?.call(details),
      child: child,
    );
  }
}
