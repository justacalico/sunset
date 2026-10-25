import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../pages/dashboard_page.dart';
import '../pages/project_page.dart';
import '../pages/settings_page.dart';
import 'side_nav.dart';
import 'title_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    const pages = [DashboardPage(), SettingsPage()];

    final destinations = <SideNavDestination>[
      (
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: l10n.navDashboard,
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final index = state.tabIndex;
        final editor = state.editor;
        final body = editor != null
            ? ProjectPage(editor: editor)
            : IndexedStack(index: index, children: pages);

        void onSelected(int i) {
          if (editor != null) state.closeProject();
          state.selectTab(i);
        }

        if (wide) {
          return Scaffold(
            body: Column(
              children: [
                if (isDesktopPlatform)
                  AppTitleBar(
                    title: editor?.project.name ?? l10n.appTitle,
                    windowActions: state.windowActions,
                  ),
                Expanded(
                  child: Row(
                    children: [
                      SideNav(
                        selectedIndex: editor == null ? index : -1,
                        onSelected: onSelected,
                        destinations: destinations,
                        header: Text(
                          l10n.appTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    ListTile(
                      leading: Icon(destinations[i].icon),
                      title: Text(destinations[i].label),
                      selected: editor == null && i == index,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(i);
                      },
                    ),
                ],
              ),
            ),
          ),
          appBar: AppBar(title: Text(l10n.appTitle)),
          body: body,
        );
      },
    );
  }
}
