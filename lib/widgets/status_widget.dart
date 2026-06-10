import 'package:flutter/material.dart';
import 'package:lacakind_frontend/data/enums/device_status.dart';

class StatusChip extends StatelessWidget {
  final DeviceStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (bg, fg) = switch (status.style) {
      DeviceStatusStyle.green  => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      DeviceStatusStyle.orange => (const Color(0xFFFFF7ED), const Color(0xFF9A3412)),
      DeviceStatusStyle.red    => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      DeviceStatusStyle.blue   => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
      DeviceStatusStyle.grey   => (const Color(0xFFF3F4F6), const Color(0xFF374151)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: textTheme.bodySmall?.copyWith(color: fg),
      ),
    );
  }
}