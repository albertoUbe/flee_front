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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      context.read<PostProvider>().loadCommunityPosts(_community.id, userId: userId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<PostProvider>().loadMoreCommunityPosts(_community.id);
    }
  }

  ShapeBorder get _dialogShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: AppTheme.borderColor(context)),
  );

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isCreator = currentUser?.id == _community.creatorId;
    final statusColor = AppTheme.communityStatusColor(
      _community.communityStatus,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _community.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (isCreator)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.textPrimary(context),
                  ),
                  color: AppTheme.dialogBg(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') _editCommunity();
                    if (value == 'delete') _deleteCommunity();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Editar',
                        style: TextStyle(color: AppTheme.textPrimary(context)),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isDesktop
                ? AppTheme.gradientDecoration(context)
                : BoxDecoration(color: AppTheme.scaffoldBg(context)),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.borderColor(context),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child:
                                  postProvider.isLoading &&
                                      postProvider
                                          .communityPosts(_community.id)
                                          .isEmpty
                                  ? const LoadingIndicator()
                                  : _buildPostList(postProvider, currentUser),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: _community.isActive
              ? FloatingActionButton(
                  backgroundColor: AppTheme.buttonBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () async {
                    final posted = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreatePostScreen(communityId: _community.id),
                      ),
                    );
                    if (posted == true && mounted) {
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      context.read<PostProvider>().loadCommunityPosts(
                        _community.id,
                        userId: userId,
                      );
                    }
                  },
                  child: const Icon(Icons.add, size: 28),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.headerBg(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_community.description.isNotEmpty) ...[
            Text(
              _community.description,
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppTheme.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormatter.communityEndLabel(_community.endDate),
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.archive_outlined,
                size: 14,
                color: AppTheme.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Archiva: ${DateFormatter.formatDate(_community.ghostDate)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
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
        onRefresh: () {
          final userId = context.read<AuthProvider>().currentUser?.id;
          return postProvider.loadCommunityPosts(_community.id, userId: userId);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add_outlined,
                    size: 56,
                    color: AppTheme.textSecondary(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin posts todavía',
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final hasMore = postProvider.communityPostsHasMore(_community.id);

    return RefreshIndicator(
      onRefresh: () => postProvider.loadCommunityPosts(_community.id),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: posts.length + (hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final post = posts[i];
          final author = postProvider.authorOf(post.userId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PostCard(
              post: post,
              author: author,
              isVoted: postProvider.isVoted(post.id),
              onVoteTap: _community.isActive && currentUser != null
                  ? () => postProvider.vote(post.id, currentUser.id)
                  : () {},
              onDeleteTap: currentUser != null && currentUser.id == post.userId
                  ? () => _deletePost(post.id)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.dialogBg(context),
        shape: _dialogShape,
        title: Text(
          'Eliminar post',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Eliminar este post definitivamente?',
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
        backgroundColor: AppTheme.dialogBg(context),
        shape: _dialogShape,
        title: Text(
          'Eliminar comunidad',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Esta acción es irreversible. ¿Eliminar la comunidad y todos sus posts?',
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
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<CommunityProvider>().deleteCommunity(
        _community.id,
      );
      if (ok && mounted) Navigator.pop(context);
    }
  }
}
