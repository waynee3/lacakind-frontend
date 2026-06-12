import 'package:flutter/material.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/dashboard_card.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class RepairCard extends StatelessWidget {
  final DashboardRepairStats repairs;
  const RepairCard({super.key, required this.repairs});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DashboardCard(
      title: 'Repair Tracking & Analytics',
      child: Column(
        children: [
          _RepairStep(
            label: 'Reported',
            count: repairs.reported,
            icon: Icons.report_outlined,
            textTheme: textTheme,
          ),
          _RepairStep(
            label: 'Picked Up',
            count: repairs.pickedUp,
            icon: Icons.local_shipping_outlined,
            textTheme: textTheme,
          ),
          _RepairStep(
            label: 'Diagnosed',
            count: repairs.diagnosed,
            icon: Icons.search_outlined,
            textTheme: textTheme,
          ),
          _RepairStep(
            label: 'Completed',
            count: repairs.completed,
            icon: Icons.check_circle_outline,
            textTheme: textTheme,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'Avg Repair Time',
                value: repairs.avgRepairDays > 0
                    ? '${repairs.avgRepairDays} days'
                    : '—',
              ),
              _StatChip(
                label: 'Completion Rate',
                value: '${repairs.completionRate}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepairStep extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final TextTheme textTheme;
  const _RepairStep({
    required this.label,
    required this.count,
    required this.icon,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: neutral300),
            ),
            child: Text('$count', style: textTheme.bodySmall?.semibold),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        Text(value, style: textTheme.bodyMedium.semibold),
      ],
    );
  }
}
