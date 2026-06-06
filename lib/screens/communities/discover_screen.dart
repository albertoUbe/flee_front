import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_model.dart';
import '../../providers/community_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/community_card.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'community_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    await Future.wait([
      context.read<PostProvider>().loadTopPosts(userId: userId),
      context.read<CommunityProvider>().loadTopCommunities(),
      if (userId != null)
        context.read<CommunityProvider>().loadMyCommunities(userId),
    ]);
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
                    'Descubrir',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppTheme.textSecondary(context)),
                      onPressed: () {
                        if (_tabController.index == 0) {
                          final uid = context.read<AuthProvider>().currentUser?.id;
                          context.read<PostProvider>().loadTopPosts(userId: uid);
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
                    _TopPostsTab(isDesktop: isDesktop, constraints: constraints, currentUser: currentUser),
                    _TopCommunitiesTab(isDesktop: isDesktop, currentUser: currentUser, onDetailBack: _loadData),
                  ],
                )
              : Column(
                  children: [
                    tabBar,
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _TopPostsTab(isDesktop: isDesktop, constraints: constraints, currentUser: currentUser),
                          _TopCommunitiesTab(isDesktop: isDesktop, currentUser: currentUser, onDetailBack: _loadData),
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

// ── Tab: Top publicaciones ────────────────────────────────────────────────────

class _TopPostsTab extends StatelessWidget {
  final bool isDesktop;
  final BoxConstraints constraints;
  final dynamic currentUser;

  const _TopPostsTab({
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
        onRefresh: () {
          final uid = context.read<AuthProvider>().currentUser?.id;
          return context.read<PostProvider>().loadTopPosts(userId: uid);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
        child: _buildColumns(context, postProvider, posts),
      ),
    );
  }

  Widget _buildColumns(BuildContext context, PostProvider postProvider, List posts) {
    final double availableWidth = constraints.maxWidth;

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
              onTap: () => _openCommunity(context, post.communityId),
            ),
          );
        }).toList(),
      );
    }

    final int columnCount = availableWidth > 1200 ? 3 : availableWidth > 750 ? 2 : 1;
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: col),
          ),
        );
      }).toList(),
    );
  }

  void _openCommunity(BuildContext context, int communityId) {
    final community = context.read<CommunityProvider>().communityById(communityId);
    if (community == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailScreen(community: community)),
    );
  }
}

// ── Tab: Top comunidades ──────────────────────────────────────────────────────

class _TopCommunitiesTab extends StatefulWidget {
  final bool isDesktop;
  final dynamic currentUser;
  final VoidCallback onDetailBack;

  const _TopCommunitiesTab({
    required this.isDesktop,
    required this.currentUser,
    required this.onDetailBack,
  });

  @override
  State<_TopCommunitiesTab> createState() => _TopCommunitiesTabState();
}

class _TopCommunitiesTabState extends State<_TopCommunitiesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    context.read<CommunityProvider>().clearSearch();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    await context.read<CommunityProvider>().searchCommunities(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<CommunityProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final hasSearch = communityProvider.searchResults != null;
    final communities = hasSearch
        ? communityProvider.searchResults!
        : communityProvider.topCommunities;

    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar comunidades...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasSearch
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );

    if (communityProvider.isSearchLoading) {
      return Column(
        children: [
          searchBar,
          const Expanded(child: Center(child: LoadingIndicator())),
        ],
      );
    }

    if (!hasSearch && communityProvider.isLoading && communities.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (communities.isEmpty) {
      final message = hasSearch
          ? 'No se encontraron comunidades con ese nombre'
          : 'No hay comunidades disponibles';
      return Column(
        children: [
          searchBar,
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.accentBlue,
              backgroundColor: AppTheme.scaffoldBg(context),
              onRefresh: () => context.read<CommunityProvider>().loadTopCommunities(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      message,
                      style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final myIds = communityProvider.myCommunities.map((c) => c.id).toSet();

    final listContent = RefreshIndicator(
      onRefresh: () => context.read<CommunityProvider>().loadTopCommunities(),
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      child: widget.isDesktop
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: communities.map((community) {
                  return SizedBox(
                    width: 380,
                    height: 150,
                    child: _cardItem(context, community, myIds),
                  );
                }).toList(),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: communities.length,
              itemBuilder: (_, i) => _cardItem(context, communities[i], myIds),
            ),
    );

    return Column(
      children: [
        searchBar,
        Expanded(child: listContent),
      ],
    );
  }

  Widget _cardItem(BuildContext context, CommunityModel community, Set<int> myIds) {
    return CommunityCard(
      community: community,
      isMember: myIds.contains(community.id),
      memberCount: community.memberCount,
      onTap: () => _openDetail(context, community),
      onFollowTap: widget.currentUser != null
          ? () => _followUnfollow(context, community.id, widget.currentUser.id)
          : null,
    );
  }

  void _openDetail(BuildContext context, CommunityModel community) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailScreen(community: community)),
    ).then((_) => widget.onDetailBack());
  }

  Future<void> _followUnfollow(BuildContext context, int communityId, int userId) async {
    await context.read<CommunityProvider>().followUnfollow(communityId, userId);
    if (context.mounted) {
      final error = context.read<CommunityProvider>().errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        context.read<CommunityProvider>().clearError();
      }
    }
  }
}
