import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_model.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/community_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'community_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final communities = context.watch<CommunityProvider>();
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
                    'Descubrir',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 0),
            child: communities.isLoading
                ? const Center(child: LoadingIndicator())
                : _buildDiscoverList(communities, currentUser?.id, isDesktop),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverList(
    CommunityProvider communities,
    int? userId,
    bool isDesktop,
  ) {
    final list = communities.allCommunities;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentBlue,
        backgroundColor: AppTheme.scaffoldBg(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Text(
                'No hay comunidades disponibles',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final myIds = communities.myCommunities.map((c) => c.id).toSet();
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      child: _buildResponsiveGrid(list, userId, myIds, isDesktop),
    );
  }

  Widget _buildResponsiveGrid(
    List<CommunityModel> list,
    int? userId,
    Set<int> myIds,
    bool isDesktop,
  ) {
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
              child: _cardItem(community, userId, myIds),
            );
          }).toList(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => _cardItem(list[i], userId, myIds),
    );
  }

  Widget _cardItem(CommunityModel community, int? userId, Set<int> myIds) {
    return CommunityCard(
      community: community,
      isMember: myIds.contains(community.id),
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
