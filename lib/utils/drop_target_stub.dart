import 'package:flutter/material.dart';

/// A drop target widget that works on all platforms.
/// On desktop, this wraps desktop_drop's DropTarget.
/// On mobile, this is a no-op wrapper.
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
  Widget build(BuildContext context) => child;
}
