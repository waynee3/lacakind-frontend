import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/dashboard_kpi.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/recent_activity.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/repair_card.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/status_snapshot_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(const DashboardEvent.started()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const DashboardEvent.refresh());
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  title: Text(
                    'Dashboard',
                    style: textTheme.titleLarge?.semibold,
                  ),
                  actions: [
                    IconButton(
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                      onPressed: () => context.read<DashboardBloc>().add(
                        const DashboardEvent.refresh(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                if (state.isLoading && state.data == null)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.errorMessage.isNotEmpty && state.data == null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage,
                            style: textTheme.bodyMedium?.withColor(
                              Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            onPressed: () => context.read<DashboardBloc>().add(
                              const DashboardEvent.refresh(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.data != null)
                  _DashboardContent(data: state.data!)
                else
                  const SliverFillRemaining(child: SizedBox()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardModel data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _SectionLabel(label: 'Overview'),
          const SizedBox(height: 12),
          DashboardKpiGrid(data: data),
          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              final twoCol = constraints.maxWidth > 700;
              if (twoCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: StatusSnapshotCard(data: data)),
                    const SizedBox(width: 20),
                    Expanded(child: RepairCard(repairs: data.repairs)),
                  ],
                );
              }
              return Column(
                children: [
                  StatusSnapshotCard(data: data),
                  const SizedBox(height: 20),
                  RepairCard(repairs: data.repairs),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          _SectionLabel(label: 'Inventory Alerts'),
          const SizedBox(height: 12),
          _AlertsPanel(alerts: data.alerts),
          const SizedBox(height: 28),

          _SectionLabel(label: 'Recent Activity'),
          const SizedBox(height: 12),
          RecentActivity(activity: data.recentActivity),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}



class _AlertsPanel extends StatelessWidget {
  final List<DashboardAlert> alerts;
  const _AlertsPanel({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(children: alerts.map((a) => _AlertTile(alert: a)).toList());
  }
}

class _AlertTile extends StatelessWidget {
  final DashboardAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (bg, fg, icon) = switch (alert.type) {
      'warning' => (
        Colors.orange.shade50,
        Colors.orange.shade800,
        Icons.warning_amber_rounded,
      ),
      'success' => (
        Colors.green.shade50,
        Colors.green.shade800,
        Icons.check_circle_outline_rounded,
      ),
      _ => (
        Colors.blue.shade50,
        Colors.blue.shade800,
        Icons.info_outline_rounded,
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.message,
              style: textTheme.bodySmall?.withColor(fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall.semibold);
  }
}
