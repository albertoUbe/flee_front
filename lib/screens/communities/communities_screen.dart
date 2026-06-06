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

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    await context.read<CommunityProvider>().loadMyCommunities(userId);
  }

  @override
  Widget build(BuildContext context) {
    final communities = context.watch<CommunityProvider>();

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
                    'Comunidades',
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
                : _buildMyList(communities, isDesktop),
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

  Widget _buildMyList(CommunityProvider communities, bool isDesktop) {
    final list = communities.myCommunities;
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
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.scaffoldBg(context),
      child: _buildResponsiveGrid(list, isDesktop),
    );
  }

  Widget _buildResponsiveGrid(List<CommunityModel> list, bool isDesktop) {
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
              child: _cardItem(community),
            );
          }).toList(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => _cardItem(list[i]),
    );
  }

  Widget _cardItem(CommunityModel community) {
    return CommunityCard(
      community: community,
      isMember: true,
      onTap: () => _openDetail(community),
      onFollowTap: null,
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
}
