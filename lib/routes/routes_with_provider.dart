// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lacakind_frontend/layouts/app_scaffold/app_scaffold.dart';
// import 'package:lacakind_frontend/logic/client/client_bloc.dart';
// import 'package:lacakind_frontend/logic/contract/contract_bloc.dart';
// import 'package:lacakind_frontend/logic/device/device_bloc.dart';
// import 'package:lacakind_frontend/logic/log/log_bloc.dart';
// import 'package:lacakind_frontend/logic/login/login_bloc.dart';
// import 'package:lacakind_frontend/screens/client/clients_screen.dart';
// import 'package:lacakind_frontend/screens/contract/contracts_screen.dart';
// import 'package:lacakind_frontend/screens/dashboard/dashboard_screen.dart';
// import 'package:lacakind_frontend/screens/device/device_screen.dart';
// import 'package:lacakind_frontend/screens/lifecycle/lifecycle_log_screen.dart';
// import 'package:lacakind_frontend/screens/login/login_screen.dart';

// part 'routes.g.dart';

// @TypedGoRoute<LoginRoute>(path: '/login')
// @immutable
// class LoginRoute extends GoRouteData with $LoginRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return NoTransitionPage(
//       child: BlocProvider(
//         create: (_) => LoginBloc(),
//         child: const LoginScreen(),
//       ),
//     );
//   }
// }

// @TypedShellRoute<AppShellRoute>(
//   routes: [
//     TypedGoRoute<DashboardRoute>(path: '/dashboard'),
//     TypedGoRoute<DeviceRoute>(path: '/device'),
//     TypedGoRoute<ClientsRoute>(path: '/clients'),
//     TypedGoRoute<LifecycleLogRoute>(path: '/lifecycle-log'),
//     TypedGoRoute<ContractsRoute>(path: '/contracts'),
//   ],
// )
// @immutable
// class AppShellRoute extends ShellRouteData {
//   const AppShellRoute();

//   @override
//   Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
//     return AppScaffold(child: navigator);
//   }
// }

// @immutable
// class DashboardRoute extends GoRouteData with $DashboardRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return const NoTransitionPage(child: DashboardScreen());
//   }
// }

// @immutable
// class DeviceRoute extends GoRouteData with $DeviceRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return NoTransitionPage(
//       child: BlocProvider(
//         create: (_) => DeviceBloc()..add(const DeviceEvent.load()),
//         child: const DeviceScreen(),
//       ),
//     );
//   }
// }

// @immutable
// class ClientsRoute extends GoRouteData with $ClientsRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return NoTransitionPage(
//       child: BlocProvider(
//         create: (_) => ClientBloc()..add(const ClientEvent.load()),
//         child: const ClientsScreen(),
//       ),
//     );
//   }
// }

// @immutable
// class ContractsRoute extends GoRouteData with $ContractsRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return NoTransitionPage(
//       child: BlocProvider(
//         create: (_) => ContractBloc()..add(const ContractEvent.load()),
//         child: const ContractsScreen(),
//       ),
//     );
//   }
// }

// @immutable
// class LifecycleLogRoute extends GoRouteData with $LifecycleLogRoute {
//   @override
//   Page<void> buildPage(BuildContext context, GoRouterState state) {
//     return NoTransitionPage(
//       child: BlocProvider(
//         create: (_) => LogBloc(),
//         child: const LifecycleLogScreen(),
//       ),
//     );
//   }
// }

// final router = GoRouter(
//   routes: $appRoutes,
//   initialLocation: '/login',
// );