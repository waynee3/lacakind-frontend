enum DeviceEventType {
  procurementArrival('Procurement & Arrival'),
  warehouseStorage('Warehouse Storage'),
  deployment('Deployment to Client'),
  maintenanceStart('Maintenance/Repair Start'),
  maintenanceComplete('Maintenance/Repair Complete'),
  swapDeployment('Swap/Spare Deployment'),
  returnFromClient('Return from Client/End of Use'),
  retirement('Retirement/Decommission');
 
  const DeviceEventType(this.label);
 
  final String label;
}
 