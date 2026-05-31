import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const UserAvatar({super.key, required this.avatarUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: avatarUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: (ctx, url, err) =>
                    Icon(Icons.person, size: radius, color: Colors.grey[600]),
                placeholder: (ctx, url) => const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : Icon(Icons.person, size: radius, color: Colors.grey[600]),
    );
  }
}
