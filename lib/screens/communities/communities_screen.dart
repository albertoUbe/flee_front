import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_model.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/community_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'community_detail_screen.dart';
import 'create_community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await Future.wait([
      context.read<CommunityProvider>().loadMyCommunities(userId),
      context.read<CommunityProvider>().loadAllCommunities(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communities = context.watch<CommunityProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: isDesktop
                ? Text(
                    'Comunidades',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentBlue,
              labelColor: AppTheme.textPrimary(context),
              unselectedLabelColor: AppTheme.textSecondary(context),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Mis comunidades'),
                Tab(text: 'Descubrir'),
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 0),
            child: communities.isLoading
                ? const Center(child: LoadingIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyList(communities, currentUser?.id, isDesktop),
                      _buildDiscoverList(
                        communities,
                        currentUser?.id,
                        isDesktop,
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCommunityScreen(),
                ),
              );
              if (result == true) _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyList(
    CommunityProvider communities,
    int? userId,
    bool isDesktop,
  ) {
    final list = communities.myCommunities;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppTheme.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no sigues ninguna comunidad',
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      child: _buildResponsiveGrid(list, userId, true, isDesktop),
    );
  }

  Widget _buildDiscoverList(
    CommunityProvider communities,
    int? userId,
    bool isDesktop,
  ) {
    final myIds = communities.myCommunities.map((c) => c.id).toSet();
    final list = communities.allCommunities;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No hay comunidades disponibles',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 16,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      child: _buildResponsiveGrid(list, userId, false, isDesktop, myIds),
    );
  }

  Widget _buildResponsiveGrid(
    List<CommunityModel> list,
    int? userId,
    bool isMyList,
    bool isDesktop, [
    Set<int>? myIds,
  ]) {
    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: list.map((community) {
            return SizedBox(
              width: 380,
              height: 150,
              child: _cardItem(community, userId, isMyList, myIds),
            );
          }).toList(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => _cardItem(list[i], userId, isMyList, myIds),
    );
  }

  Widget _cardItem(
    CommunityModel community,
    int? userId,
    bool isMyList,
    Set<int>? myIds,
  ) {
    final bool isMember = isMyList
        ? true
        : (myIds?.contains(community.id) ?? false);
    return CommunityCard(
      community: community,
      isMember: isMember,
      onTap: () => _openDetail(community),
      onFollowTap: userId != null
          ? () => _followUnfollow(community.id, userId)
          : null,
    );
  }

  void _openDetail(CommunityModel community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _followUnfollow(int communityId, int userId) async {
    await context.read<CommunityProvider>().followUnfollow(communityId, userId);
    if (mounted) {
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
