import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_indicator.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Paleta de colores unificada de Flee
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: Colors
              .transparent, // Permite ver el fondo degradado del MainShell
          // El AppBar solo se muestra en Escritorio. En móvil lo maneja el MainShell.
          appBar: isDesktop
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'Feed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: textMuted),
                      onPressed: () => context.read<PostProvider>().loadFeed(),
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : null,

          body: Center(
            child: ConstrainedBox(
              // Acotamos el ancho del Feed en PC para una lectura cómoda (estilo Twitter/LinkedIn)
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 650 : double.infinity,
              ),
              child: postProvider.isLoading && postProvider.feedPosts.isEmpty
                  ? const Center(child: LoadingIndicator())
                  : postProvider.feedPosts.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: accentBlue,
                      backgroundColor: bgDark,
                      onRefresh: () => context.read<PostProvider>().loadFeed(),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: isDesktop ? 0 : 8,
                        ),
                        itemCount: postProvider.feedPosts.length,
                        itemBuilder: (context, index) {
                          final post = postProvider.feedPosts[index];
                          final author = postProvider.authorOf(post.userId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: PostCard(
                              post: post,
                              author: author,
                              isVoted: postProvider.isVoted(post.id),
                              onVoteTap: currentUser != null
                                  ? () => postProvider.vote(
                                      post.id,
                                      currentUser.id,
                                    )
                                  : () {},
                              onDeleteTap:
                                  currentUser != null &&
                                      currentUser.id == post.userId
                                  ? () => _deletePost(post.id, post.communityId)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: accentBlue,
      backgroundColor: bgDark,
      onRefresh: () => context.read<PostProvider>().loadFeed(),
      child: ListView(
        children: const [
          SizedBox(height: 140),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.feed_outlined, size: 64, color: textMuted),
                SizedBox(height: 16),
                Text(
                  'No hay posts todavía',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Únete a una comunidad y crea el primero',
                  style: TextStyle(color: textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(int postId, int communityId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgDark,
        title: const Text(
          'Eliminar post',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este post?',
          style: TextStyle(color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<PostProvider>().deletePost(postId, communityId);
    }
  }
}
