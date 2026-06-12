import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/dashboard/widget/dashboard_card.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> activity;
  const RecentActivity({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (activity.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No recent activity', style: textTheme.bodyMedium),
        ),
      );
    }

    return DashboardCard(
      title: '',
      child: Column(
        children: activity.take(8).map((op) {
          final action = op['action'] as String? ?? '';
          final devices = List<String>.from(op['affectedDevices'] ?? []);
          final createdBy = op['createdBy'] as String? ?? '';
          final ts = op['timestamp'] != null
              ? DateTime.tryParse(op['timestamp'].toString())
              : null;
          final label = _actionLabel(action);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: _actionColor(action),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _actionColor(action))
                            ),
                            child: Text(
                              label,
                              style: textTheme.bodySmall?.copyWith(
                                color: _actionColor(action),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${devices.length} device${devices.length == 1 ? '' : 's'}',
                            style: textTheme.bodySmall?.withColor(neutral500),
                          ),
                        ],
                      ),
                      if (ts != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormat('dd MMM yyyy · HH:mm').format(ts)}  ·  by $createdBy',
                          style: textTheme.bodySmall?.withColor(neutral400),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _actionLabel(String action) {
    const labels = {
      'deployment': 'Deployment to Client',
      'procurementarrival': 'Procurement & Arrival',
      'warehousestorage': 'Warehouse Storage',
      'maintenancestart': 'Maintenance Start',
      'maintenancecomplete': 'Maintenance Complete',
      'swapdeployment': 'Swap Deployment',
      'return': 'Return from Client',
      'retirement': 'Retirement',
      'bulk_import': 'Bulk Import',
      'bulk_delete': 'Bulk Delete',
    };
    return labels[action.toLowerCase()] ?? action;
  }

  Color _actionColor(String action) {
    switch (action.toLowerCase()) {
      case 'deployment':
      case 'swapdeployment':
        return const Color(0xFF16A34A);
      case 'maintenancestart':
        return const Color(0xFFEA580C);
      case 'retirement':
      case 'bulk_delete':
        return const Color(0xFFDC2626);
      case 'return':
        return const Color(0xFF7C3AED);
      default:
        return neutral500;
    }
  }
}
