import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_model.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/community_card.dart';
import '../../widgets/loading_indicator.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidades'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis comunidades'),
            Tab(text: 'Descubrir'),
          ],
        ),
      ),
      body: communities.isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyList(communities, currentUser?.id),
                _buildDiscoverList(communities, currentUser?.id),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
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
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildMyList(CommunityProvider communities, int? userId) {
    final list = communities.myCommunities;
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aún no sigues ninguna comunidad',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => CommunityCard(
          community: list[i],
          isMember: true,
          onTap: () => _openDetail(list[i]),
          onFollowTap: userId != null
              ? () => _followUnfollow(list[i].id, userId)
              : null,
        ),
      ),
    );
  }

  Widget _buildDiscoverList(CommunityProvider communities, int? userId) {
    final myIds = communities.myCommunities.map((c) => c.id).toSet();
    final list = communities.allCommunities;
    if (list.isEmpty) {
      return const Center(
        child: Text('No hay comunidades disponibles',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final isMember = myIds.contains(list[i].id);
          return CommunityCard(
            community: list[i],
            isMember: isMember,
            onTap: () => _openDetail(list[i]),
            onFollowTap: userId != null
                ? () => _followUnfollow(list[i].id, userId)
                : null,
          );
        },
      ),
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
          SnackBar(content: Text(error)),
        );
        context.read<CommunityProvider>().clearError();
      }
    }
  }
}
