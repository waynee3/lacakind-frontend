import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/layouts/app_scaffold/app_scaffold.dart';
import 'package:lacakind_frontend/screens/client/clients_screen.dart';
import 'package:lacakind_frontend/screens/contract/contracts_screen.dart';
import 'package:lacakind_frontend/screens/dashboard/dashboard_screen.dart';
import 'package:lacakind_frontend/screens/device/device_screen.dart';
import 'package:lacakind_frontend/screens/lifecycle/lifecycle_log_screen.dart';
import 'package:lacakind_frontend/screens/login/login_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<LoginRoute>(path: "/login")
@immutable
class LoginRoute extends GoRouteData with $LoginRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: LoginScreen(),
    );
  }
}

@TypedShellRoute<AppShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(path: '/dashboard'),
    TypedGoRoute<DeviceRoute>(path: '/device'),
    TypedGoRoute<ClientsRoute>(path: '/clients'),
    TypedGoRoute<LifecycleLogRoute>(path: '/lifecycle-log'),
    TypedGoRoute<ContractsRoute>(path: '/contracts'),
  ],
)
@immutable
class AppShellRoute extends ShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppScaffold(child: navigator);
  }
}

@immutable
class DashboardRoute extends GoRouteData with $DashboardRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: DashboardScreen());
  }
}

@immutable
class DeviceRoute extends GoRouteData with $DeviceRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: DeviceScreen());
  }
}

@immutable
class LifecycleLogRoute extends GoRouteData with $LifecycleLogRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: LifecycleLogScreen());
  }
}

@immutable
class ClientsRoute extends GoRouteData with $ClientsRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: ClientsScreen());
  }
}

@immutable
class ContractsRoute extends GoRouteData with $ContractsRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: ContractsScreen());
  }
}

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: "/login",
);
