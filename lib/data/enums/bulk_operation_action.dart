enum BulkOperationAction {
  procurementarrival('Procurement & Arrival',  'procurementarrival'),
  warehousestorage  ('Warehouse Storage',       'warehousestorage'),
  deployment        ('Deployment to Client',    'deployment'),
  maintenancestart  ('Maintenance/Repair Start','maintenancestart'),
  maintenancecomplete('Maintenance/Repair Complete', 'maintenancecomplete'),
  swapdeployment    ('Swap/Spare Deployment',   'swapdeployment'),
  returnFromClient  ('Return from Client',      'return'),
  retirement        ('Retirement/Decommission', 'retirement'),
  bulkImport        ('Bulk Import',             'bulk_import'),
  bulkDelete        ('Bulk Delete',             'bulk_delete');

  const BulkOperationAction(this.label, this.backendKey);

  final String label;

  final String backendKey;

  static BulkOperationAction? fromValue(String? v) {
    if (v == null) return null;
    final normalised = v.toLowerCase().trim();
    for (final a in values) {
      if (a.backendKey == normalised) return a;
    }
    return null;
  }
}