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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PostProvider>().loadFeed(),
          ),
        ],
      ),
      body: postProvider.isLoading && postProvider.feedPosts.isEmpty
          ? const LoadingIndicator()
          : postProvider.feedPosts.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () => context.read<PostProvider>().loadFeed(),
                  child: ListView.builder(
                    itemCount: postProvider.feedPosts.length,
                    itemBuilder: (context, index) {
                      final post = postProvider.feedPosts[index];
                      final author = postProvider.authorOf(post.userId);
                      return PostCard(
                        post: post,
                        author: author,
                        isVoted: postProvider.isVoted(post.id),
                        onVoteTap: currentUser != null
                            ? () => postProvider.vote(post.id, currentUser.id)
                            : () {},
                        onDeleteTap:
                            currentUser != null && currentUser.id == post.userId
                                ? () => _deletePost(post.id, post.communityId)
                                : null,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: () => context.read<PostProvider>().loadFeed(),
      child: ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.feed_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay posts todavía',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Únete a una comunidad y crea el primero',
                  style: TextStyle(color: Colors.grey),
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
        title: const Text('Eliminar post'),
        content: const Text('¿Estás seguro de que quieres eliminar este post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<PostProvider>().deletePost(postId, communityId);
    }
  }
}
