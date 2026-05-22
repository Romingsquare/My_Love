// lib/app/router.dart
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/cosmos/cosmos_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/cosmos',
      builder: (ctx, state) => const CosmosScreen(),
    ),
  ],
);
