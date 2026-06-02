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

  // Paleta de colores unificada y compartida de Flee
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadCommunityPosts(_community.id);
    });
  }

  ThemeData _dialogTheme(BuildContext context) {
    return Theme.of(
      context,
    ).copyWith(dialogBackgroundColor: bgDark, scaffoldBackgroundColor: bgDark);
  }

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
          backgroundColor: bgDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _community.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF131C35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') _editCommunity();
                    if (value == 'delete') _deleteCommunity();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Editar',
                        style: TextStyle(color: Colors.white),
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
                ? const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.3,
                      colors: [gradientStart, gradientEnd],
                      stops: [0.0, 1.0],
                    ),
                  )
                : const BoxDecoration(color: bgDark),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
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
                  backgroundColor: buttonBlue,
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
                      context.read<PostProvider>().loadCommunityPosts(
                        _community.id,
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
        color: const Color(0xFF0F172A).withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_community.description.isNotEmpty) ...[
            Text(
              _community.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormatter.communityEndLabel(_community.endDate),
                  style: const TextStyle(color: textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.archive_outlined, size: 14, color: textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Archiva: ${DateFormatter.formatDate(_community.ghostDate)}',
                  style: const TextStyle(color: textMuted, fontSize: 12),
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
        onRefresh: () => postProvider.loadCommunityPosts(_community.id),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add_outlined, size: 56, color: textMuted),
                  SizedBox(height: 12),
                  Text(
                    'Sin posts todavía',
                    style: TextStyle(
                      color: textMuted,
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

    return RefreshIndicator(
      onRefresh: () => postProvider.loadCommunityPosts(_community.id),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: posts.length,
        itemBuilder: (_, i) {
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
      builder: (ctx) => Theme(
        data: _dialogTheme(context),
        child: AlertDialog(
          title: const Text(
            'Eliminar post',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Eliminar este post definitivamente?',
            style: TextStyle(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: textMuted)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Eliminar'),
            ),
          ],
        ),
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
      builder: (ctx) => Theme(
        data: _dialogTheme(context),
        child: AlertDialog(
          title: const Text(
            'Eliminar comunidad',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Esta acción es irreversible. ¿Eliminar la comunidad y todos sus posts?',
            style: TextStyle(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: textMuted)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Eliminar'),
            ),
          ],
        ),
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
