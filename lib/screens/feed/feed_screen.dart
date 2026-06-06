import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../communities/community_detail_screen.dart';

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
      final userId = context.read<AuthProvider>().currentUser?.id;
      context.read<PostProvider>().loadFeed(userId: userId);
      context.read<CommunityProvider>().loadAllCommunities();
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
          backgroundColor: Colors.transparent,
          appBar: isDesktop
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Feed',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: AppTheme.textSecondary(context),
                      ),
                      onPressed: () => context.read<PostProvider>().loadFeed(userId: currentUser?.id),
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : null,
          body: postProvider.isLoading && postProvider.feedPosts.isEmpty
              ? const Center(child: LoadingIndicator())
              : postProvider.feedPosts.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: AppTheme.accentBlue,
                  backgroundColor: AppTheme.scaffoldBg(context),
                  onRefresh: () => context.read<PostProvider>().loadFeed(userId: currentUser?.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: isDesktop ? 16 : 8,
                    ),
                    child: _buildColumns(
                      postProvider,
                      currentUser,
                      isDesktop,
                      constraints.maxWidth,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildColumns(
    PostProvider postProvider,
    currentUser,
    bool isDesktop,
    double availableWidth,
  ) {
    final posts = postProvider.feedPosts;

    if (!isDesktop) {
      return Column(
        children: posts.map((post) {
          final author = postProvider.authorOf(post.userId);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: PostCard(
              post: post,
              author: author,
              isVoted: postProvider.isVoted(post.id),
              onVoteTap: currentUser != null
                  ? () => postProvider.vote(post.id, currentUser.id)
                  : () {},
              onDeleteTap: currentUser != null && currentUser.id == post.userId
                  ? () => _deletePost(post.id, post.communityId)
                  : null,
              onTap: () => _openCommunity(post.communityId),
            ),
          );
        }).toList(),
      );
    }

    final int columnCount = availableWidth > 1200
        ? 3
        : availableWidth > 750
        ? 2
        : 1;
    final List<List<Widget>> columns = List.generate(columnCount, (_) => []);

    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final author = postProvider.authorOf(post.userId);
      columns[i % columnCount].add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PostCard(
            post: post,
            author: author,
            isVoted: postProvider.isVoted(post.id),
            onVoteTap: currentUser != null
                ? () => postProvider.vote(post.id, currentUser.id)
                : () {},
            onDeleteTap: currentUser != null && currentUser.id == post.userId
                ? () => _deletePost(post.id, post.communityId)
                : null,
            onTap: () => _openCommunity(post.communityId),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((col) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: col,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _openCommunity(int communityId) {
    final community =
        context.read<CommunityProvider>().communityById(communityId);
    if (community == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      onRefresh: () => context.read<PostProvider>().loadFeed(
        userId: context.read<AuthProvider>().currentUser?.id,
      ),
      child: ListView(
        children: [
          const SizedBox(height: 140),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.feed_outlined,
                  size: 64,
                  color: AppTheme.textSecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay posts todavía',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete a una comunidad y crea el primero',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
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
        backgroundColor: AppTheme.dialogBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.borderColor(context)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(
          'Eliminar post',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este post?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
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
