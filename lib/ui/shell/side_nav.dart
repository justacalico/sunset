import 'package:flutter/material.dart';

typedef SideNavDestination = ({
  IconData icon,
  IconData selectedIcon,
  String label,
});

class SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<SideNavDestination> destinations;
  final Widget? header;
  final String? footerLabel;
  final VoidCallback? onFooter;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    this.header,
    this.footerLabel,
    this.onFooter,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: 232,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: header!,
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  12,
                  header == null ? 16 : 4,
                  12,
                  16,
                ),
                itemCount: destinations.length,
                itemBuilder: (context, index) => SideNavItem(
                  destination: destinations[index],
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                ),
              ),
            ),
            if (onFooter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: SideNavItem(
                  destination: (
                    icon: Icons.add_circle_outline,
                    selectedIcon: Icons.add_circle,
                    label: footerLabel ?? '',
                  ),
                  selected: false,
                  onTap: onFooter!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SideNavItem extends StatelessWidget {
  final SideNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const SideNavItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;
    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: 20,
      color: foreground,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? colors.secondaryContainer : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
