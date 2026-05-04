import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final String emailOrUser;

  static const logoPath = "assets/images/flee_logo_blue.png";
  static const logoOut = "Log out";
  static const profileText = "Profile";

  const SidebarWidget({super.key, required this.emailOrUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF0D1224),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOGO
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(logoPath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),

          // PERFIL SUPERIOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?u=alberto",
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emailOrUser.split('@')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "@alberto",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 20),

          // MENÚ
          _buildMenuItem(Icons.grid_view_rounded, "Flees", isActive: true),
          _buildMenuItem(Icons.people_outline, "Members"),
          _buildMenuItem(Icons.chat_bubble_outline, "Communities"),
          _buildMenuItem(Icons.settings_outlined, "Settings"),

          const Spacer(),

          // PERFIL INFERIOR CON MENÚ DESPLEGABLE
          Theme(
            // Esto es para que el menú tenga el fondo oscuro
            data: Theme.of(
              context,
            ).copyWith(cardColor: const Color(0xFF1A1F2E)),
            child: PopupMenuButton<String>(
              // El offset mueve el menú hacia ARRIBA (valor negativo en Y)
              offset: const Offset(0, -60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  // Volver al login borrando el historial de navegación
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      SizedBox(width: 12),
                      Text(logoOut, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
              // El "child" es el diseño de tu botón de perfil actual
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?u=alberto",
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "alberto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          profileText,
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1E88E5).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF42A5F5) : Colors.white54,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? const Color(0xFF42A5F5) : Colors.white70,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
