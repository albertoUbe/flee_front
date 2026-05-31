import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../core/utils/date_formatter.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final UserModel? author;
  final bool isVoted;
  final VoidCallback onVoteTap;
  final VoidCallback? onDeleteTap;

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    required this.isVoted,
    required this.onVoteTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: UserAvatar(avatarUrl: author?.avatarUrl ?? '', radius: 20),
            title: Text(
              author?.name ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormatter.formatDateTime(post.postDate),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: onDeleteTap != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: onDeleteTap,
                    tooltip: 'Eliminar',
                  )
                : null,
          ),
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(post.text),
            ),
          if (post.hasMedia)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (ctx, url, err) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isVoted ? Icons.favorite : Icons.favorite_border,
                    color: isVoted ? Colors.red : Colors.grey,
                  ),
                  onPressed: onVoteTap,
                  tooltip: isVoted ? 'Quitar voto' : 'Votar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
