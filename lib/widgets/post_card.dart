import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../core/utils/date_formatter.dart';
import '../core/theme/app_theme.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: avatar + autor + fecha + borrar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
            child: Row(
              children: [
                UserAvatar(avatarUrl: author?.avatarUrl ?? '', radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author?.name ?? 'Usuario',
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDateTime(post.postDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.iconMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDeleteTap != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppTheme.iconMuted(context),
                      size: 20,
                    ),
                    onPressed: onDeleteTap,
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ),

          // Texto del post
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                post.text,
                style: TextStyle(
                  color: AppTheme.textPrimary(context).withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),

          // Imagen adjunta
          if (post.hasMedia)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.mediaUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    height: 200,
                    color: AppTheme.placeholderBg(context),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentBlue,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    height: 100,
                    color: AppTheme.placeholderBg(context),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppTheme.iconMuted(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Fila de acciones (like)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isVoted ? Icons.favorite : Icons.favorite_border,
                    color: isVoted
                        ? Colors.redAccent
                        : AppTheme.iconMuted(context),
                    size: 20,
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
