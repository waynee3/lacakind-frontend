import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String current = GoRouterState.of(context).uri.toString();

    final dashboardLoc = DashboardRoute().location;
    final deviceLoc = DeviceRoute().location;
    final clientsLoc = ClientsRoute().location;
    final contractsLoc = ContractsRoute().location;
    final lifecycleLogLoc = LifecycleLogRoute().location;

    return Column(
      children: [
        NavigationItem(
          label: "Dashboard",
          icon: Icons.dashboard_outlined,
          iconActive: Icons.dashboard,
          location: dashboardLoc,
          onClick: () => DashboardRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Devices",
          icon: Icons.dashboard_outlined,
          iconActive: Icons.dashboard,
          location: deviceLoc,
          onClick: () => DeviceRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Clients",
          icon: Icons.dashboard_outlined,
          iconActive: Icons.dashboard,
          location: clientsLoc,
          onClick: () => ClientsRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Contracts",
          icon: Icons.dashboard_outlined,
          iconActive: Icons.dashboard,
          location: contractsLoc,
          onClick: () => ContractsRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Lifecycle Log",
          icon: Icons.dashboard_outlined,
          iconActive: Icons.dashboard,
          location: lifecycleLogLoc,
          onClick: () => LifecycleLogRoute().go(context),
          currentLocation: current,
        ),
      ],
    );
  }
}

class NavigationItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onClick;
  final String location;
  final String currentLocation;

  // if iconActive is not null, the icon will be replaced with iconActive when the item is active
  final IconData? iconActive;

  const NavigationItem({
    super.key,
    required this.label,
    required this.icon,
    this.iconActive,
    required this.onClick,
    required this.location,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentLocation.startsWith(location);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        dense: true,
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isActive ? textTheme.bodyMedium.bold : textTheme.bodyMedium,
        ),
        leading: Icon(
          (isActive && iconActive != null) ? iconActive : icon,
          weight: isActive ? 700 : 400,
        ),
        onTap: onClick,
      ),
    );
  }
}
