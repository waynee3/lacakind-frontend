class DashboardRepairStats {
  final int reported;
  final int pickedUp;
  final int diagnosed;
  final int completed;
  final int avgRepairDays;
  final int completionRate;

  const DashboardRepairStats({
    required this.reported,
    required this.pickedUp,
    required this.diagnosed,
    required this.completed,
    required this.avgRepairDays,
    required this.completionRate,
  });

  factory DashboardRepairStats.fromJson(Map<String, dynamic> json) =>
      DashboardRepairStats(
        reported: (json['reported'] as num? ?? 0).toInt(),
        pickedUp: (json['pickedUp'] as num? ?? 0).toInt(),
        diagnosed: (json['diagnosed'] as num? ?? 0).toInt(),
        completed: (json['completed'] as num? ?? 0).toInt(),
        avgRepairDays: (json['avgRepairDays'] as num? ?? 0).toInt(),
        completionRate: (json['completionRate'] as num? ?? 0).toInt(),
      );
}

class DashboardAlert {
  final String type;
  final String icon;
  final String message;

  const DashboardAlert({
    required this.type,
    required this.icon,
    required this.message,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) => DashboardAlert(
    type: json['type'] as String? ?? 'info',
    icon: json['icon'] as String? ?? 'info',
    message: json['message'] as String? ?? '',
  );
}

class DashboardDeviceStats {
  final int total;
  final int deployed;
  final int underRepair;
  final int inWarehouse;
  final int repaired;
  final int returned;
  final int retired;
  final int utilizationRate;
  final Map<String, int> statusBreakdown;

  const DashboardDeviceStats({
    required this.total,
    required this.deployed,
    required this.underRepair,
    required this.inWarehouse,
    required this.repaired,
    required this.returned,
    required this.retired,
    required this.utilizationRate,
    required this.statusBreakdown,
  });

  factory DashboardDeviceStats.fromJson(Map<String, dynamic> json) {
    final raw =
        (json['statusBreakdown'] as Map?)?.cast<String, dynamic>() ?? {};
    return DashboardDeviceStats(
      total: (json['total'] as num? ?? 0).toInt(),
      deployed: (json['deployed'] as num? ?? 0).toInt(),
      underRepair: (json['underRepair'] as num? ?? 0).toInt(),
      inWarehouse: (json['inWarehouse'] as num? ?? 0).toInt(),
      repaired: (json['repaired'] as num? ?? 0).toInt(),
      returned: (json['returned'] as num? ?? 0).toInt(),
      retired: (json['retired'] as num? ?? 0).toInt(),
      utilizationRate: (json['utilizationRate'] as num? ?? 0).toInt(),
      statusBreakdown: raw.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}

class DashboardModel {
  final DashboardDeviceStats devices;
  final int clients;
  final int totalContracts;
  final int activeContracts;
  final DashboardRepairStats repairs;
  final int? procureToDeployDays;
  final List<DashboardAlert> alerts;
  final List<Map<String, dynamic>> recentActivity;

  const DashboardModel({
    required this.devices,
    required this.clients,
    required this.totalContracts,
    required this.activeContracts,
    required this.repairs,
    this.procureToDeployDays,
    required this.alerts,
    required this.recentActivity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final contracts = json['contracts'] as Map<String, dynamic>? ?? {};
    return DashboardModel(
      devices: DashboardDeviceStats.fromJson(
        json['devices'] as Map<String, dynamic>? ?? {},
      ),
      clients: (json['clients'] as num? ?? 0).toInt(),
      totalContracts: (contracts['total'] as num? ?? 0).toInt(),
      activeContracts: (contracts['active'] as num? ?? 0).toInt(),
      repairs: DashboardRepairStats.fromJson(
        json['repairs'] as Map<String, dynamic>? ?? {},
      ),
      procureToDeployDays: (json['procureToDeployDays'] as num?)?.toInt(),
      alerts: (json['alerts'] as List? ?? [])
          .map((e) => DashboardAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recentActivity'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}
