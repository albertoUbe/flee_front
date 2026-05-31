import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_indicator.dart';
import '../post/create_post_screen.dart';
import 'edit_community_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late CommunityModel _community;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadCommunityPosts(_community.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isCreator = currentUser?.id == _community.creatorId;
    final statusColor = AppTheme.communityStatusColor(_community.communityStatus);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_community.name, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _community.communityStatus,
                  style: TextStyle(fontSize: 12, color: statusColor),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (isCreator)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') _editCommunity();
                if (value == 'delete') _deleteCommunity();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: postProvider.isLoading &&
                    postProvider.communityPosts(_community.id).isEmpty
                ? const LoadingIndicator()
                : _buildPostList(postProvider, currentUser),
          ),
        ],
      ),
      floatingActionButton: _community.isActive
          ? FloatingActionButton(
              onPressed: () async {
                final posted = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreatePostScreen(communityId: _community.id),
                  ),
                );
                if (posted == true && mounted) {
                  // ignore: use_build_context_synchronously
                  context.read<PostProvider>().loadCommunityPosts(_community.id);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_community.description.isNotEmpty)
            Text(_community.description,
                style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                DateFormatter.communityEndLabel(_community.endDate),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.archive_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Archiva: ${DateFormatter.formatDate(_community.ghostDate)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(PostProvider postProvider, currentUser) {
    final posts = postProvider.communityPosts(_community.id);
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            postProvider.loadCommunityPosts(_community.id),
        child: ListView(
          children: const [
            SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Icon(Icons.post_add_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Sin posts todavía',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => postProvider.loadCommunityPosts(_community.id),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (_, i) {
          final post = posts[i];
          final author = postProvider.authorOf(post.userId);
          return PostCard(
            post: post,
            author: author,
            isVoted: postProvider.isVoted(post.id),
            onVoteTap: _community.isActive && currentUser != null
                ? () => postProvider.vote(post.id, currentUser.id)
                : () {},
            onDeleteTap: currentUser != null && currentUser.id == post.userId
                ? () => _deletePost(post.id)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar post'),
        content: const Text('¿Eliminar este post?'),
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
      await context.read<PostProvider>().deletePost(postId, _community.id);
    }
  }

  Future<void> _editCommunity() async {
    final updated = await Navigator.push<CommunityModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditCommunityScreen(community: _community),
      ),
    );
    if (updated != null) setState(() => _community = updated);
  }

  Future<void> _deleteCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comunidad'),
        content: const Text(
            'Esta acción es irreversible. ¿Eliminar la comunidad y todos sus posts?'),
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
      final ok = await context
          .read<CommunityProvider>()
          .deleteCommunity(_community.id);
      if (ok && mounted) Navigator.pop(context);
    }
  }
}
