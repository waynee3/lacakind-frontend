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
    final deviceLoc = DeviceListRoute().location;
    final clientsLoc = ClientListRoute().location;
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
          icon: Icons.devices_outlined,
          iconActive: Icons.devices,
          location: deviceLoc,
          onClick: () => DeviceListRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Clients",
          icon: Icons.supervised_user_circle_outlined,
          iconActive: Icons.supervised_user_circle,
          location: clientsLoc,
          onClick: () => ClientListRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Contracts",
          icon: Icons.file_present_outlined,
          iconActive: Icons.file_present,
          location: contractsLoc,
          onClick: () => ContractsRoute().go(context),
          currentLocation: current,
        ),
        NavigationItem(
          label: "Lifecycle Log",
          icon: Icons.receipt_long_outlined,
          iconActive: Icons.receipt_long,
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
          style: isActive ? textTheme.bodyLarge.bold : textTheme.bodyLarge,
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
