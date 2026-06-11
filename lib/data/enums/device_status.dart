enum DeviceStatus {
  inStock('InStock'),
  inWarehouse('In Warehouse'),
  deployed('Deployed'),
  underRepair('Under Repair'),
  repaired('Repaired'),
  spareDeployed('Spare Deployed'),
  returned('Returned'),
  retired('Retired');

  const DeviceStatus(this.value);

  final String value;

  static DeviceStatus? fromValue(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    for (final s in DeviceStatus.values) {
      if (s.value == trimmed) return s;
    }
    return null;
  }

  String get label => value;

  DeviceStatusStyle get style {
    switch (this) {
      case DeviceStatus.deployed:
      case DeviceStatus.spareDeployed:
        return DeviceStatusStyle.green;
      case DeviceStatus.underRepair:
        return DeviceStatusStyle.orange;
      case DeviceStatus.retired:
        return DeviceStatusStyle.red;
      case DeviceStatus.repaired:
      case DeviceStatus.returned:
        return DeviceStatusStyle.blue;
      case DeviceStatus.inStock:
      case DeviceStatus.inWarehouse:
        return DeviceStatusStyle.grey;
    }
  }
}

enum DeviceStatusStyle { green, orange, red, blue, grey }