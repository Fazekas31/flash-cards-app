import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/decks/presentation/pages/decks_page.dart';
import '../../features/study/presentation/pages/deck_detail_page.dart';
import '../../features/study/presentation/pages/study_session_page.dart';

GoRouter createRouter(bool isFirstLaunch, AuthBloc authBloc) {
  return GoRouter(
    initialLocation: isFirstLaunch ? '/onboarding' : '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final bool isAuth = authState is AuthAuthenticated;

      final bool isGoingToLogin = state.matchedLocation == '/login';
      final bool isGoingToRegister = state.matchedLocation == '/register';
      final bool isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (isGoingToOnboarding) return null;

      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      if (isAuth && (isGoingToLogin || isGoingToRegister)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DecksPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/study/:deckId',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId'] ?? '';
          return DeckDetailPage(deckId: deckId);
        },
      ),
      GoRoute(
        path: '/study/:deckId/session',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId'] ?? '';
          return StudySessionPage(deckId: deckId);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
