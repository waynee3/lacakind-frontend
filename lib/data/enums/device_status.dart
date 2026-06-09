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

  static DeviceStatus? fromValue(String? value) {
    if (value == null) return null;
    for (final s in DeviceStatus.values) {
      if (s.value.toLowerCase() == value.toLowerCase()) return s;
    }
    return null;
  }

  String get label => value;

  // Returns a display-friendly color hint (used by UI chips)
  DeviceStatusStyle get style {
    switch (this) {
      case DeviceStatus.deployed:
        return DeviceStatusStyle.green;
      case DeviceStatus.spareDeployed:
        return DeviceStatusStyle.green;
      case DeviceStatus.underRepair:
        return DeviceStatusStyle.orange;
      case DeviceStatus.retired:
        return DeviceStatusStyle.red;
      case DeviceStatus.returned:
        return DeviceStatusStyle.grey;
      case DeviceStatus.repaired:
        return DeviceStatusStyle.blue;
      case DeviceStatus.inStock:
        return DeviceStatusStyle.grey;
      case DeviceStatus.inWarehouse:
        return DeviceStatusStyle.grey;
    }
  }
}

enum DeviceStatusStyle { green, orange, red, blue, grey }
