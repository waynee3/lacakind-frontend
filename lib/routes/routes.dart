import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/layouts/app_scaffold/app_scaffold.dart';
import 'package:lacakind_frontend/screens/client/clients_screen.dart';
import 'package:lacakind_frontend/screens/contract/contracts_screen.dart';
import 'package:lacakind_frontend/screens/dashboard/dashboard_screen.dart';
import 'package:lacakind_frontend/screens/device/device_detail/bloc/device_detail_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_detail/device_detail_screen.dart';
import 'package:lacakind_frontend/screens/device/device_form/bloc/device_form_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_form/device_form_screen.dart';
import 'package:lacakind_frontend/screens/device/device_list/bloc/device_list_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_list/device_list_screen.dart';
import 'package:lacakind_frontend/screens/lifecycle/lifecycle_log_screen.dart';
import 'package:lacakind_frontend/screens/login/bloc/login_bloc.dart';
import 'package:lacakind_frontend/screens/login/login_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData with $LoginRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: BlocProvider(
        create: (_) => LoginBloc(),
        child: const LoginScreen(),
      ),
    );
  }
}

@TypedShellRoute<AppShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(path: '/dashboard'),
    TypedGoRoute<DeviceListRoute>(
      path: '/device-list',
      routes: [
        TypedGoRoute<DeviceNewRoute>(path: 'new'),
        TypedGoRoute<DeviceDetailRoute>(
          path: ':id',
          routes: [
            TypedGoRoute<DeviceEditRoute>(path: 'edit'),
          ],
        ),
      ],
    ),
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
class DeviceListRoute extends GoRouteData with $DeviceListRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: BlocProvider(
        create: (_) => DeviceListBloc()..add(const DeviceListEvent.started()),
        child: const DeviceListScreen(),
      ),
    );
  }
}

@immutable
class DeviceNewRoute extends GoRouteData with $DeviceNewRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: BlocProvider(
        create: (_) => DeviceFormBloc()..add(const DeviceFormEvent.started()),
        child: const DeviceFormScreen(),
      ),
    );
  }
}

@immutable
class DeviceDetailRoute extends GoRouteData with $DeviceDetailRoute {
  const DeviceDetailRoute({required this.id});
  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: BlocProvider(
        create: (_) => DeviceDetailBloc()..add(DeviceDetailEvent.started(id)),
        child: DeviceDetailScreen(deviceId: id),
      ),
    );
  }
}

@immutable
class DeviceEditRoute extends GoRouteData with $DeviceEditRoute {
  const DeviceEditRoute({required this.id});
  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: BlocProvider(
        create: (_) => DeviceFormBloc()..add(DeviceFormEvent.startedEdit(id)),
        child: DeviceFormScreen(deviceId: id),
      ),
    );
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
class LifecycleLogRoute extends GoRouteData with $LifecycleLogRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: LifecycleLogScreen());
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
  initialLocation: '/login',
);