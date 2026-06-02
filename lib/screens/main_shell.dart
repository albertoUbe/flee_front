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

  // Ruta del logo unificada con LoginScreen
  static const String pathLogo = "assets/images/flee_logo_blue.png";

  // Paleta de colores extraída de tu LoginScreen
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

  static const _tabs = [FeedScreen(), CommunitiesScreen(), ProfileScreen()];

  static const _labels = ['Feed', 'Comunidades', 'Perfil'];

  static const _icons = [
    Icons.home_outlined,
    Icons.group_outlined,
    Icons.person_outlined,
  ];

  static const _activeIcons = [Icons.home, Icons.group, Icons.person];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mismo criterio de escritorio que tu login (> 600px)
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: bgDark,
          // 1. AppBar con botón de menú (Hamburguesa) SOLO para móvil
          appBar: !isDesktop
              ? AppBar(
                  backgroundColor: bgDark,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    _labels[_currentIndex],
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : null,

          // 2. Drawer lateral SOLO para móvil
          drawer: !isDesktop ? _buildMobileDrawer() : null,

          // 3. Estructura principal responsiva
          body: Container(
            decoration: isDesktop
                ? const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.3,
                      colors: [gradientStart, gradientEnd],
                      stops: [0.0, 1.0],
                    ),
                  )
                : const BoxDecoration(color: bgDark),
            child: Row(
              children: [
                // Barra lateral fija si es escritorio
                if (isDesktop) _buildDesktopNavigationRail(),

                // Contenido principal de la pantalla actual
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

  /// Barra de navegación lateral para Escritorio
  Widget _buildDesktopNavigationRail() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: bgDark,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.06,
            ), // Borde sutil del login
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Centra los hijos horizontalmente
                  children: [
                    SizedBox(
                      height: 90,
                      child: Image.asset(pathLogo, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Flee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Elementos del menú estilizados
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
                      // Efecto de fondo sutil al estar seleccionado
                      selectedTileColor: accentBlue.withValues(alpha: 0.15),
                      leading: Icon(
                        isSelected ? _activeIcons[i] : _icons[i],
                        color: isSelected ? accentBlue : textMuted,
                      ),
                      title: Text(
                        _labels[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : textMuted,
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
          ],
        ),
      ),
    );
  }

  /// Menú desplegable (Drawer) para pantallas Móviles
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: bgDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera superior con Logo e Imagen CENTRADOS (Móvil)
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Centra los hijos horizontalmente
                  children: [
                    SizedBox(
                      height: 55,
                      child: Image.asset(pathLogo, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Flee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white12),

            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, i) {
                  final bool isSelected = _currentIndex == i;
                  return ListTile(
                    onTap: () {
                      setState(() => _currentIndex = i);
                      Navigator.pop(context); // Cierra el Drawer tras pulsar
                    },
                    leading: Icon(
                      isSelected ? _activeIcons[i] : _icons[i],
                      color: isSelected ? accentBlue : textMuted,
                    ),
                    title: Text(
                      _labels[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : textMuted,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
