import 'package:flutter/material.dart';

class CommunityCardWidget extends StatelessWidget {
  final String title;
  final String timeLeft;
  final String imagePath;
  final int chatCount;
  final int memberCount;
  final VoidCallback? onTap;

  const CommunityCardWidget({
    super.key,
    required this.title,
    required this.timeLeft,
    required this.imagePath,
    this.chatCount = 0,
    this.memberCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Eliminamos el ancho fijo para que el GridView lo maneje
        decoration: BoxDecoration(
          color: const Color(0xFF1A2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGEN CON ICONO SUPERPUESTO
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imagePath,
                    height:
                        100, // Bajamos a 100 para ganar esos 10-13px de margen
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Evita el error statusCode: 0 mostrando un placeholder
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(
                      Icons.sync,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // 2. CONTENIDO (Flexible para evitar overflow)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribuye el espacio
                  children: [
                    // Título y tiempo
                    Text(
                      "$title - $timeLeft",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize:
                            13, // Reducimos un punto para asegurar espacio
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Avatares
                    _buildStackedAvatars(),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.chat_bubble,
                            "$chatCount Chats",
                          ),
                        ),
                        Expanded(child: _buildStatItem(Icons.group, "Members")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9BB4D1)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9BB4D1),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStackedAvatars() {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          _avatarCircle('https://i.pravatar.cc/150?u=1', 0),
          _avatarCircle('https://i.pravatar.cc/150?u=2', 16),
          Positioned(
            left: 32,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A2433), width: 2),
              ),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black,
                child: Icon(Icons.whatshot, size: 12, color: Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle(String url, double leftPadding) {
    return Positioned(
      left: leftPadding,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1A2433), width: 2),
        ),
        child: CircleAvatar(
          radius: 10,
          backgroundImage: NetworkImage(url),
          backgroundColor: Colors.grey[900],
          // Manejo de error individual para cada avatar
          onBackgroundImageError: (exception, stackTrace) => {},
        ),
      ),
    );
  }
}
