import 'package:flutter/material.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/dashboard_card.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class StatusSnapshotCard extends StatelessWidget {
  final DashboardModel data;
  const StatusSnapshotCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final d = data.devices;
    final total = d.total > 0 ? d.total : 1;

    final rows = [
      _StatusRow('Deployed', d.deployed, const Color(0xFF16A34A)),
      _StatusRow('Under Repair', d.underRepair, const Color(0xFFEA580C)),
      _StatusRow('In Warehouse', d.inWarehouse, neutral400),
      _StatusRow('Repaired', d.repaired, const Color(0xFF0369A1)),
      _StatusRow('Returned', d.returned, const Color(0xFF7C3AED)),
      _StatusRow('Retired', d.retired, neutral300),
    ];

    return DashboardCard(
      title: 'Inventory Status Snapshot',
      child: Column(
        children: rows.map((row) {
          final pct = row.count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.label, style: textTheme.bodySmall),
                    Text('${row.count}', style: textTheme.bodySmall?.semibold),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: neutral100,
                    valueColor: AlwaysStoppedAnimation(row.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusRow {
  final String label;
  final int count;
  final Color color;
  const _StatusRow(this.label, this.count, this.color);
}
