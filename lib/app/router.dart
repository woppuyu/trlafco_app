import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trlafco_app/features/auth/login_screen.dart';
import 'package:trlafco_app/features/logistics/classification/classification_screen.dart';
import 'package:trlafco_app/features/logistics/dashboard/logistics_dashboard_screen.dart';
import 'package:trlafco_app/features/logistics/deliveries/deliveries_screen.dart';
import 'package:trlafco_app/features/logistics/farmer_suppliers/logistics_farmer_suppliers_screen.dart';
import 'package:trlafco_app/features/logistics/shell/logistics_shell_screen.dart';
import 'package:trlafco_app/features/manager/analytics/manager_analytics_screen.dart';
import 'package:trlafco_app/features/manager/dashboard/manager_dashboard_screen.dart';
import 'package:trlafco_app/features/manager/records/manager_records_screen.dart';
import 'package:trlafco_app/features/manager/settings/settings_screen.dart';
import 'package:trlafco_app/features/manager/shell/manager_shell_screen.dart';
import 'package:trlafco_app/features/shared/screens/loading_screen.dart';
import 'package:trlafco_app/models/user_role.dart';
import 'package:trlafco_app/state/app_state.dart';

GoRouter createRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: appState,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final loading = state.matchedLocation == '/loading';
      final role = appState.currentRole;

      if (appState.isLoading && !loading) {
        return '/loading';
      }

      if (!appState.isLoading && loading) {
        if (role == UserRole.manager) return '/manager/dashboard';
        if (role == UserRole.logistics) return '/logistics/dashboard';
        return '/login';
      }

      if (role == null) {
        return loggingIn ? null : '/login';
      }

      if (role == UserRole.manager && state.matchedLocation.startsWith('/logistics')) {
        return '/manager/dashboard';
      }
      if (role == UserRole.logistics && state.matchedLocation.startsWith('/manager')) {
        return '/logistics/dashboard';
      }

      if (loggingIn) {
        return role == UserRole.manager
            ? '/manager/dashboard'
            : '/logistics/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: const LoginScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ManagerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/dashboard',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const ManagerDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/records',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const ManagerRecordsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'farmer/:id',
                    builder: (context, state) => FarmerSupplierDetailScreen(
                      farmerId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/analytics',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const ManagerAnalyticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/manager/settings',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return LogisticsShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/logistics/dashboard',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const LogisticsDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/logistics/deliveries',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const DeliveriesScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DeliveryDetailScreen(
                      deliveryId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/logistics/classification',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const ClassificationScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/logistics/farmer-suppliers',
                pageBuilder: (context, state) => _slidePage(
                  key: state.pageKey,
                  child: const LogisticsFarmerSuppliersScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _slidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0.12, 0),
        end: Offset.zero,
      );
      return SlideTransition(
        position: tween.animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
