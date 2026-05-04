import 'package:flee_front/ui/auth/widgets/community_card_widget.dart';
import 'package:flee_front/ui/auth/widgets/side_bar_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String emailOrUser;

  const HomeScreen({super.key, required this.emailOrUser});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Definimos si la pantalla es "móvil" o "pequeña" (menos de 900px)
        final bool isSmallScreen = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1F),
          // Si la pantalla es pequeña, añadimos un Drawer y un AppBar con el botón menú
          drawer: isSmallScreen
              ? Drawer(child: SidebarWidget(emailOrUser: emailOrUser))
              : null,
          appBar: isSmallScreen
              ? AppBar(
                  backgroundColor: const Color(0xFF0D1224),
                  elevation: 0,
                  title: const Text(
                    "FLEE",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          body: Row(
            children: [
              // 1. SIDEBAR: Solo se muestra fijo si la pantalla es grande
              if (!isSmallScreen) SidebarWidget(emailOrUser: emailOrUser),

              // 2. ÁREA DE CONTENIDO PRINCIPAL
              Expanded(
                child: Column(
                  children: [
                    // Solo mostramos la barra de búsqueda si hay espacio
                    _buildTopBar(),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Fleeting moments",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 25),

                            _buildSectionHeader("Popular communities"),
                            const SizedBox(height: 16),

                            // Grid responsivo
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    // CAMBIO CLAVE: 2 columnas en pequeño, 3 en grande
                                    crossAxisCount: isSmallScreen ? 2 : 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 240,
                                  ),
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return CommunityCardWidget(
                                  title: "Horror films",
                                  timeLeft: "3hr left",
                                  imagePath:
                                      "https://picsum.photos/seed/${index + 10}/400/250",
                                  chatCount: index + 2,
                                  memberCount: 10 + index,
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            _buildSectionHeader("My fleeting communities"),
                            const SizedBox(height: 16),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    // CAMBIO CLAVE: 2 columnas en pequeño, 3 en grande
                                    crossAxisCount: isSmallScreen ? 2 : 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 240,
                                  ),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return CommunityCardWidget(
                                  title: "Sunset Photos",
                                  timeLeft: "3hr left",
                                  imagePath:
                                      "https://picsum.photos/seed/${index + 10}/400/250",
                                  chatCount: index + 2,
                                  memberCount: 10 + index,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Tus funciones de soporte se mantienen igual pero con retoques de overflow ---

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white54, size: 20),
                  hintText: "Search communities...",
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Usamos Expanded para que el texto largo no empuje al botón fuera de la pantalla
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "See all",
            style: TextStyle(color: Color(0xFF42A5F5)),
          ),
        ),
      ],
    );
  }
}
