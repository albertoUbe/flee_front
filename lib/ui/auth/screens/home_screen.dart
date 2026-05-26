import 'package:flee_front/domain/entities/community.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/ui/auth/viewmodels/community_view_model.dart';
import 'package:flee_front/ui/auth/widgets/community_card_widget.dart';
import 'package:flee_front/ui/auth/widgets/floating_button_community_widget.dart';
import 'package:flee_front/ui/auth/widgets/side_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const title = "FLEE";
  static const popular = "Popular communities";
  static const subtitle = "Fleeting moments";
  static const myCommunities = "My fleeting communities";
  static const search = "Search communities...";
  static const allCommunities = "See all";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CommunityViewModel>();
      vm.loadAll();
      vm.loadMyCommunities(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommunityViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1F),
          drawer: isSmallScreen
              ? Drawer(child: SidebarWidget(emailOrUser: widget.user.email))
              : null,
          appBar: isSmallScreen
              ? AppBar(
                  backgroundColor: const Color(0xFF0D1224),
                  elevation: 0,
                  title: const Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : null,

          floatingActionButton: FloatingButtonCommunity(
            creatorId: widget.user.id,
          ),

          body: Row(
            children: [
              if (!isSmallScreen) SidebarWidget(emailOrUser: widget.user.email),

              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(),

                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.errorMessage != null
                          ? Center(
                              child: Text(
                                vm.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  _buildSectionHeader(popular),
                                  const SizedBox(height: 16),

                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isSmallScreen ? 2 : 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 240,
                                        ),
                                    itemCount: vm.allCommunities.length,
                                    itemBuilder: (context, index) {
                                      final Community c =
                                          vm.allCommunities[index];
                                      return CommunityCardWidget(
                                        title: c.name,
                                        timeLeft: c.timeToLeft,
                                        imagePath:
                                            "https://picsum.photos/seed/${c.id}/400/250",
                                        chatCount: 0,
                                        memberCount: 0,
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 32),

                                  _buildSectionHeader(myCommunities),
                                  const SizedBox(height: 16),

                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isSmallScreen ? 2 : 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 240,
                                        ),
                                    itemCount: vm.myCommunities.length,
                                    itemBuilder: (context, index) {
                                      final Community c =
                                          vm.myCommunities[index];
                                      return CommunityCardWidget(
                                        title: c.name,
                                        timeLeft: c.timeToLeft,
                                        imagePath:
                                            "https://picsum.photos/seed/${c.id}/400/250",
                                        chatCount: 0,
                                        memberCount: 0,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white54, size: 20),
                  hintText: search,
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            allCommunities,
            style: TextStyle(color: Color(0xFF42A5F5)),
          ),
        ),
      ],
    );
  }
}
