import 'package:flee_front/core/theme/app_theme.dart';
import 'package:flee_front/core/theme/theme_dark_light.dart';
import 'package:flutter/material.dart';
import 'feed/feed_screen.dart';
import 'communities/communities_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const String pathLogo = "assets/images/flee_logo_blue.png";

  static const _labels = ['Feed', 'Comunidades', 'Perfil'];
  static const _icons = [
    Icons.home_outlined,
    Icons.group_outlined,
    Icons.person_outlined,
  ];
  static const _activeIcons = [Icons.home, Icons.group, Icons.person];

  static const _tabs = [FeedScreen(), CommunitiesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg(context),
          appBar: !isDesktop
              ? AppBar(
                  backgroundColor: AppTheme.sidebarBg(context),
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: AppTheme.textPrimary(context),
                  ),
                  title: Text(
                    _labels[_currentIndex],
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 18,
                    ),
                  ),
                )
              : null,
          drawer: !isDesktop ? _buildMobileDrawer(isDark) : null,
          body: Container(
            decoration: isDesktop
                ? AppTheme.gradientDecoration(context)
                : BoxDecoration(color: AppTheme.scaffoldBg(context)),
            child: Row(
              children: [
                if (isDesktop) _buildDesktopNavigationRail(isDark),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _tabs),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopNavigationRail(bool isDark) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppTheme.sidebarBg(context),
        border: Border(right: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 90,
                      child: Image.asset(pathLogo, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Flee',
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, i) {
                  final bool isSelected = _currentIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _currentIndex = i),
                      selected: isSelected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selectedTileColor: AppTheme.accentBlue.withValues(
                        alpha: 0.15,
                      ),
                      leading: Icon(
                        isSelected ? _activeIcons[i] : _icons[i],
                        color: isSelected
                            ? AppTheme.accentBlue
                            : AppTheme.textSecondary(context),
                      ),
                      title: Text(
                        _labels[i],
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.textPrimary(context)
                              : AppTheme.textSecondary(context),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: ListTile(
                onTap: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: AppTheme.placeholderBg(context),
                leading: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppTheme.textSecondary(context),
                ),
                title: Text(
                  isDark ? 'Modo claro' : 'Modo oscuro',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(bool isDark) {
    return Drawer(
      backgroundColor: AppTheme.sidebarBg(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 55,
                      child: Image.asset(pathLogo, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Flee',
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: AppTheme.borderColor(context)),
            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, i) {
                  final bool isSelected = _currentIndex == i;
                  return ListTile(
                    onTap: () {
                      setState(() => _currentIndex = i);
                      Navigator.pop(context);
                    },
                    leading: Icon(
                      isSelected ? _activeIcons[i] : _icons[i],
                      color: isSelected
                          ? AppTheme.accentBlue
                          : AppTheme.textSecondary(context),
                    ),
                    title: Text(
                      _labels[i],
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.textPrimary(context)
                            : AppTheme.textSecondary(context),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: AppTheme.borderColor(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: ListTile(
                onTap: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  Navigator.pop(context);
                },
                leading: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppTheme.textSecondary(context),
                ),
                title: Text(
                  isDark ? 'Modo claro' : 'Modo oscuro',
                  style: TextStyle(color: AppTheme.textSecondary(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
