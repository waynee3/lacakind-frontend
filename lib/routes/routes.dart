import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/screens/login_screen.dart';

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

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: "/login",
);