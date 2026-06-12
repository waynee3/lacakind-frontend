import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/layouts/app_scaffold/widget/app_drawer.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/styles/theme_cubit.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'LacakInd',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      context.watch<ThemeCubit>().state == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  ),
                ],
              ),
            ),
            FutureBuilder<String?>(
              future: authRepo.currentEmail(),
              builder: (context, snapshot) {
                final email = snapshot.data ?? '';
                final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

                return InkWell(
                  onTap: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          'Log Out',
                          style: textTheme.headlineMedium.bold,
                        ),
                        content: Text(
                          'Are you sure you want to log out?',
                          style: textTheme.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                    if (result == true && context.mounted) {
                      await authRepo.logout();
                      if (context.mounted) LoginRoute().go(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: neutral200,
                          child: Text(
                            initial,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: neutral700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.logout_rounded, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: double.infinity,
              width: 280,
              child: SingleChildScrollView(child: const AppDrawer()),
            ),
            VerticalDivider(width: 1, thickness: 1, color: neutral200),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
