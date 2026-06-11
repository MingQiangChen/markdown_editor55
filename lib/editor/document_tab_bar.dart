import 'package:flutter/material.dart';

import 'document_tab.dart';

/// A horizontal tab bar for managing multiple document tabs.
class DocumentTabBar extends StatelessWidget {
  const DocumentTabBar({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
  });

  final List<DocumentTab> tabs;
  final String activeTabId;
  final ValueChanged<String> onTabSelected;
  final ValueChanged<String> onTabClosed;
  final VoidCallback onNewTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final isActive = tab.id == activeTabId;
                  return _TabItem(
                    tab: tab,
                    isActive: isActive,
                    canClose: tabs.length > 1,
                    onTap: () => onTabSelected(tab.id),
                    onClose: () => onTabClosed(tab.id),
                  );
                },
              ),
            ),
            // New tab button.
            InkWell(
              onTap: onNewTab,
              child: SizedBox(
                width: 36,
                height: 38,
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.canClose,
    required this.onTap,
    required this.onClose,
  });

  final DocumentTab tab;
  final bool isActive;
  final bool canClose;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeBg = colorScheme.surface;
    final inactiveBg = colorScheme.surfaceContainerLow;
    final activeBorder = colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 180,
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeBorder : Colors.transparent,
              width: 2,
            ),
            right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 15,
              color:
                  isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                tab.isDirty ? '● ${tab.title}' : tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (canClose)
              GestureDetector(
                onTap: onClose,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
