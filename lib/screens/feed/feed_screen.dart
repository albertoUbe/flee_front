import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/community_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../communities/community_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadTopPosts();
      context.read<CommunityProvider>().loadTopCommunities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        final tabBar = TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: AppTheme.textSecondary(context),
          indicatorColor: AppTheme.accentBlue,
          tabs: const [
            Tab(icon: Icon(Icons.article_outlined), text: 'Publicaciones'),
            Tab(icon: Icon(Icons.group_outlined), text: 'Comunidades'),
          ],
        );

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
                      onPressed: () {
                        if (_tabController.index == 0) {
                          context.read<PostProvider>().loadTopPosts();
                        } else {
                          context.read<CommunityProvider>().loadTopCommunities();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: tabBar,
                  ),
                )
              : null,
          body: isDesktop
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _PostsTab(isDesktop: isDesktop, constraints: constraints, currentUser: currentUser),
                    _CommunitiesTab(isDesktop: isDesktop, currentUser: currentUser),
                  ],
                )
              : Column(
                  children: [
                    tabBar,
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _PostsTab(isDesktop: isDesktop, constraints: constraints, currentUser: currentUser),
                          _CommunitiesTab(isDesktop: isDesktop, currentUser: currentUser),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _PostsTab extends StatelessWidget {
  final bool isDesktop;
  final BoxConstraints constraints;
  final dynamic currentUser;

  const _PostsTab({
    required this.isDesktop,
    required this.constraints,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final posts = postProvider.topPosts;

    if (postProvider.isLoading && posts.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (posts.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.accentBlue,
        backgroundColor: AppTheme.scaffoldBg(context),
        onRefresh: () => context.read<PostProvider>().loadTopPosts(),
        child: ListView(
          children: [
            const SizedBox(height: 140),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.feed_outlined, size: 64, color: AppTheme.textSecondary(context)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay publicaciones todavía',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a una comunidad y crea el primero',
                    style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      onRefresh: () => context.read<PostProvider>().loadTopPosts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isDesktop ? 16 : 8,
        ),
        child: _buildColumns(context, postProvider, posts, isDesktop, constraints.maxWidth),
      ),
    );
  }

  Widget _buildColumns(
    BuildContext context,
    PostProvider postProvider,
    List posts,
    bool isDesktop,
    double availableWidth,
  ) {
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
                  ? () => _deletePost(context, post.id, post.communityId)
                  : null,
              onTap: () => _openCommunity(context, post.communityId),
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
                ? () => _deletePost(context, post.id, post.communityId)
                : null,
            onTap: () => _openCommunity(context, post.communityId),
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

  void _openCommunity(BuildContext context, int communityId) {
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

  Future<void> _deletePost(BuildContext context, int postId, int communityId) async {
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
    if (confirm == true && context.mounted) {
      await context.read<PostProvider>().deletePost(postId, communityId);
    }
  }
}

class _CommunitiesTab extends StatelessWidget {
  final bool isDesktop;
  final dynamic currentUser;

  const _CommunitiesTab({required this.isDesktop, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final communities = communityProvider.topCommunities;

    if (communityProvider.isLoading && communities.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (communities.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.accentBlue,
        backgroundColor: AppTheme.scaffoldBg(context),
        onRefresh: () => context.read<CommunityProvider>().loadTopCommunities(),
        child: ListView(
          children: [
            const SizedBox(height: 140),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_outlined, size: 64, color: AppTheme.textSecondary(context)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay comunidades todavía',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      onRefresh: () => context.read<CommunityProvider>().loadTopCommunities(),
      child: isDesktop
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: communities.map((community) {
                  final isMember = currentUser != null &&
                      communityProvider.myCommunities
                          .any((c) => c.id == community.id);
                  return SizedBox(
                    width: 380,
                    child: CommunityCard(
                      community: community,
                      isMember: isMember,
                      memberCount: community.memberCount,
                      onTap: () => _openCommunity(context, community),
                      onFollowTap: currentUser != null
                          ? () => communityProvider.followUnfollow(
                              community.id, currentUser.id)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                final isMember = currentUser != null &&
                    communityProvider.myCommunities
                        .any((c) => c.id == community.id);
                return CommunityCard(
                  community: community,
                  isMember: isMember,
                  memberCount: community.memberCount,
                  onTap: () => _openCommunity(context, community),
                  onFollowTap: currentUser != null
                      ? () => communityProvider.followUnfollow(
                          community.id, currentUser.id)
                      : null,
                );
              },
            ),
    );
  }

  void _openCommunity(BuildContext context, community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
  }
}
