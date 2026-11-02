import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/favourites/screens/favourites_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/scanner/screens/scanner_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'shell_scaffold.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const products = '/products';
  static const productDetail = '/products/:id';
  static const favourites = '/favourites';
  static const scanner = '/scanner';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.products,
    debugLogDiagnostics: false,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final onLoginPage = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !onLoginPage) return AppRoutes.login;
      if (isAuthenticated && onLoginPage) return AppRoutes.products;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.products,
            name: 'products',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProductListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'productDetail',
                pageBuilder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return MaterialPage(
                    key: state.pageKey,
                    child: ProductDetailScreen(productId: id),
                  );
                },
              ),
            ],
          ),

          GoRoute(
            path: AppRoutes.favourites,
            name: 'favourites',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FavouritesScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.scanner,
        name: 'scanner',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ScannerScreen(),
        ),
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
}
