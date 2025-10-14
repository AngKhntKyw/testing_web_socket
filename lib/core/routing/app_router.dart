import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_socket/features/auth/controller/auth_controller.dart';
import 'package:test_socket/features/auth/views/login_view.dart';
import 'package:test_socket/features/auth/views/signup_view.dart';
import 'package:test_socket/features/home/views/navigation_bar.dart';

// 1. Create a dedicated ChangeNotifier that listens to the auth state.
final goRouterRefreshNotifierProvider = Provider((ref) {
  return GoRouterRefreshNotifier(ref);
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    // Listen to the auth controller provider.
    // When the auth state changes, this will call `notifyListeners()`
    // and trigger the GoRouter to re-evaluate its routing rules.
    ref.listen<AsyncValue<bool>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

// 2. Update the routerProvider to use our new Notifier.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch our new refresh notifier.
  final refreshNotifier = ref.watch(goRouterRefreshNotifierProvider);
  // Watch the auth state for redirection logic.
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    // Use the new notifier as the refreshListenable.
    refreshListenable: refreshNotifier,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
      GoRoute(
        path: '/',
        builder: (context, state) => const NavigationBarPage(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.value ?? false;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // Prevent redirecting while the auth state is loading.
      if (authState.isLoading) {
        return null;
      }

      if (isLoggingIn && isAuthenticated) {
        return '/';
      }

      if (!isLoggingIn && !isAuthenticated) {
        return '/login';
      }

      return null;
    },
  );
});
