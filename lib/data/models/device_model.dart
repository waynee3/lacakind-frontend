import 'package:lacakind_frontend/data/enums/device_status.dart';
import 'package:lacakind_frontend/data/models/lifecycle_event_model.dart';

class DeviceModel {
  final String id;
  final String serialNumber;
  final String? modelType;
  final DeviceStatus? status;
  final String? currentLocation;
  final String? supplier;
  final String? batchNumber;
  final double? cost;
  final DateTime? purchaseDate;
  final DateTime? activationDate;
  final DateTime? warrantyExpiry;
  final String? clientId;
  final String? clientName;
  final List<String> linkedContractIds;
  final List<String> repairIncidents;
  final List<LifecycleEvent> lifecycleEvents;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceModel({
    required this.id,
    required this.serialNumber,
    this.modelType,
    this.status,
    this.currentLocation,
    this.supplier,
    this.batchNumber,
    this.cost,
    this.purchaseDate,
    this.activationDate,
    this.warrantyExpiry,
    this.clientId,
    this.clientName,
    this.linkedContractIds = const [],
    this.repairIncidents = const [],
    this.lifecycleEvents = const [],
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final rawClient = json['client'];
    final String? clientId;
    final String? clientName;

    if (rawClient is Map) {
      clientId   = rawClient['id']?.toString() ??
                   rawClient['_id']?.toString();
      clientName = rawClient['name'] as String?;
    } else {
      clientId   = rawClient?.toString();
      clientName = null;
    }

    return DeviceModel(
      id:             json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serialNumber:   json['serialNumber'] ?? '',
      modelType:      json['modelType'],
      status:         DeviceStatus.fromValue(json['status']),
      currentLocation:json['currentLocation'],
      supplier:       json['supplier'],
      batchNumber:    json['batchNumber'],
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      purchaseDate:   _date(json['purchaseDate']),
      activationDate: _date(json['activationDate']),
      warrantyExpiry: _date(json['warrantyExpiry']),
      clientId:       clientId,
      clientName:     clientName,
      linkedContractIds: List<String>.from(json['linkedContractIds'] ?? []),
      repairIncidents:   List<String>.from(json['repairIncidents'] ?? []),
      lifecycleEvents: (json['lifecycleEvents'] as List? ?? [])
          .map((e) => LifecycleEvent.fromJson(e))
          .toList(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static DateTime? _date(dynamic v) =>
      v != null ? DateTime.tryParse(v.toString()) : null;
}