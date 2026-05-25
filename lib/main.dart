import 'package:flee_front/data/repositories/auth_repository_impl.dart';
import 'package:flee_front/data/repositories/community_repository_impl.dart';
import 'package:flee_front/data/repositories/post_repository_impl.dart';
import 'package:flee_front/data/services/api_service.dart';
import 'package:flee_front/domain/entities/user.dart';
import 'package:flee_front/domain/repositories/user_repository.dart';
import 'package:flee_front/domain/use_cases/authentication/sign_in_use_case.dart';
import 'package:flee_front/domain/use_cases/authentication/sign_up_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/all_communities_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/community_by_user_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/create_community_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/follow_unfollow_use_case.dart';
import 'package:flee_front/domain/use_cases/communities/manage_admin_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/all_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/create_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/delete_post_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/post_by_community_use_case.dart';
import 'package:flee_front/domain/use_cases/posts/vote_post_use_case.dart';
import 'package:flee_front/ui/auth/screens/home_screen.dart';
import 'package:flee_front/ui/auth/screens/sign_in_screen.dart';
import 'package:flee_front/ui/auth/screens/sign_up_screen.dart';
import 'package:flee_front/ui/auth/screens/welcome_screen.dart';
import 'package:flee_front/ui/auth/viewmodels/community_view_model.dart';
import 'package:flee_front/ui/auth/viewmodels/post_view_model.dart';
import 'package:flee_front/ui/auth/viewmodels/sign_in_view_model.dart';
import 'package:flee_front/ui/auth/viewmodels/sign_up_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final api = ApiService();

  final UserRepository authRepository = AuthRepositoryImpl(api);
  final communityRepository = CommunityRepositoryImpl(api);
  final postRepository = PostRepositoryImpl(api);

  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);

  final allCommunitiesUseCase = AllCommunitiesUseCase(communityRepository);
  final communityByUserUseCase = CommunityByUserUseCase(communityRepository);
  final createCommunityUseCase = CreateCommunityUseCase(communityRepository);
  final followUnfollowUseCase = FollowUnfollowUseCase(communityRepository);
  final manageAdminUseCase = ManageAdminUseCase(communityRepository);

  final allPostUseCase = AllPostUseCase(postRepository);
  final postByCommunityUseCase = PostByCommunityUseCase(postRepository);
  final createPostUseCase = CreatePostUseCase(postRepository);
  final deletePostUseCase = DeletePostUseCase(postRepository);
  final votePostUseCase = VotePostUseCase(postRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignInViewModel(signInUseCase)),
        ChangeNotifierProvider(create: (_) => SignUpViewModel(signUpUseCase)),
        ChangeNotifierProvider(
          create: (_) => CommunityViewModel(
            allCommunitiesUseCase: allCommunitiesUseCase,
            communityByUserUseCase: communityByUserUseCase,
            createCommunityUseCase: createCommunityUseCase,
            followUnfollowUseCase: followUnfollowUseCase,
            manageAdminUseCase: manageAdminUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PostViewModel(
            allPostUseCase: allPostUseCase,
            postByCommunityUseCase: postByCommunityUseCase,
            createPostUseCase: createPostUseCase,
            deletePostUseCase: deletePostUseCase,
            votePostUseCase: votePostUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flee',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42A5F5),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const SignInScreen(),
        '/register': (context) => const SignUpScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(user: user),
          );
        }
        return null;
      },
    );
  }
}
