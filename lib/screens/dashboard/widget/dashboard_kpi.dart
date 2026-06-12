import 'package:flutter/material.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class DashboardKpiGrid extends StatelessWidget {
  final DashboardModel data;
  const DashboardKpiGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data.devices;
    final r = data.repairs;

    final cards = [
      _DashboardKpiData(
        label: 'Total Devices',
        value: '${d.total}',
        icon: Icons.devices_rounded,
        color: const Color(0xFF16A34A),
      ),
      _DashboardKpiData(
        label: 'Deployed',
        value: '${d.deployed}',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF16A34A),
      ),
      _DashboardKpiData(
        label: 'Under Repair',
        value: '${d.underRepair}',
        icon: Icons.build_outlined,
        color: const Color(0xFFEA580C),
      ),
      _DashboardKpiData(
        label: 'In Warehouse',
        value: '${d.inWarehouse}',
        icon: Icons.warehouse_outlined,
        color: neutral500,
      ),
      _DashboardKpiData(
        label: 'Utilization Rate',
        value: '${d.utilizationRate}%',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _DashboardKpiData(
        label: 'Active Contracts',
        value: '${data.activeContracts}',
        icon: Icons.assignment_outlined,
        color: const Color(0xFF0369A1),
      ),
      _DashboardKpiData(
        label: 'Total Clients',
        value: '${data.clients}',
        icon: Icons.business_outlined,
        color: const Color(0xFF0369A1),
      ),
      _DashboardKpiData(
        label: 'Avg. Repair Time',
        value: r.avgRepairDays > 0 ? '${r.avgRepairDays}d' : '—',
        icon: Icons.timer_outlined,
        color: const Color(0xFFD97706),
      ),
      _DashboardKpiData(
        label: 'Procure to Deploy',
        value: data.procureToDeployDays != null
            ? '${data.procureToDeployDays}d'
            : '—',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF059669),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: cards.map((c) => _DashboardKpiCard(data: c)).toList(),
        );
      },
    );
  }
}

class _DashboardKpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DashboardKpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _DashboardKpiCard extends StatelessWidget {
  final _DashboardKpiData data;
  const _DashboardKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 18, color: data.color),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
              ),
              Text(data.label, style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
