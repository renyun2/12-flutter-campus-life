import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/card/presentation/campus_card_page.dart';
import '../../features/card/presentation/topup_page.dart';
import '../../features/canteen/presentation/canteen_page.dart';
import '../../features/canteen/presentation/dish_detail_page.dart';
import '../../features/clubs/presentation/club_detail_page.dart';
import '../../features/clubs/presentation/clubs_page.dart';
import '../../features/discover/presentation/discover_page.dart';
import '../../features/grades/presentation/grade_detail_page.dart';
import '../../features/grades/presentation/grades_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/library/presentation/book_detail_page.dart';
import '../../features/library/presentation/borrow_records_page.dart';
import '../../features/library/presentation/library_page.dart';
import '../../features/lost_found/presentation/lost_found_page.dart';
import '../../features/lost_found/presentation/publish_lost_page.dart';
import '../../features/map/presentation/map_page.dart';
import '../../features/market/presentation/market_detail_page.dart';
import '../../features/market/presentation/market_page.dart';
import '../../features/market/presentation/publish_market_page.dart';
import '../../features/messages/presentation/messages_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/schedule/presentation/course_detail_page.dart';
import '../../features/schedule/presentation/schedule_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import 'router_refresh.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authed = ref.read(authProvider) != null;
      final loc = state.matchedLocation;
      const public = ['/', '/login'];
      if (public.contains(loc)) {
        if (authed && loc == '/login') return '/home';
        return null;
      }
      if (!authed) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/schedule', builder: (context, state) => const SchedulePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/discover', builder: (context, state) => const DiscoverPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          ]),
        ],
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/course/:id', builder: (c, s) => CourseDetailPage(courseId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/grades', builder: (c, s) => const GradesPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/grades/:termId', builder: (c, s) => GradeDetailPage(termId: s.pathParameters['termId']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/library', builder: (c, s) => const LibraryPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/book/:id', builder: (c, s) => BookDetailPage(bookId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/library/records', builder: (c, s) => const BorrowRecordsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/canteen', builder: (c, s) => const CanteenPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/dish/:id', builder: (c, s) => DishDetailPage(dishId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/campus-card', builder: (c, s) => const CampusCardPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/campus-card/topup', builder: (c, s) => const TopupPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/lost-found', builder: (c, s) => const LostFoundPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/lost-found/publish', builder: (c, s) => const PublishLostPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/clubs', builder: (c, s) => const ClubsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/club/:id', builder: (c, s) => ClubDetailPage(clubId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/map', builder: (c, s) => const MapPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/market', builder: (c, s) => const MarketPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/market/:id', builder: (c, s) => MarketDetailPage(itemId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: _rootKey, path: '/market/publish', builder: (c, s) => const PublishMarketPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/messages', builder: (c, s) => const MessagesPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/search',
        builder: (c, s) => SearchPage(query: s.uri.queryParameters['q'] ?? ''),
      ),
    ],
  );
});
