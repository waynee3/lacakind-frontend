import 'package:lacakind_frontend/data/enums/bulk_operation_action.dart';

class BulkOperationModel {
  final String id;
  final String bulkOpId;
  final BulkOperationAction? action;
  final String actionRaw;
  final List<String> affectedDevices;
  final String createdBy;
  final DateTime timestamp;
  final String description;
  final String associatedLocation;
  final String relatedReference;
  final int? totalRecords;
  final int? successfulRecords;
  final int? failedRecords;
  final List<String> importErrors;
  final DateTime? createdAt;

  const BulkOperationModel({
    required this.id,
    required this.bulkOpId,
    this.action,
    required this.actionRaw,
    required this.affectedDevices,
    required this.createdBy,
    required this.timestamp,
    required this.description,
    required this.associatedLocation,
    required this.relatedReference,
    this.totalRecords,
    this.successfulRecords,
    this.failedRecords,
    required this.importErrors,
    this.createdAt,
  });

  factory BulkOperationModel.fromJson(Map<String, dynamic> json) {
    final rawAction = json['action'] as String? ?? '';
    return BulkOperationModel(
      id:                 json['_id'] ?? json['id'] ?? '',
      bulkOpId:           json['bulkOpId'] ?? '',
      action:             BulkOperationAction.fromValue(rawAction),
      actionRaw:          rawAction,
      affectedDevices:    List<String>.from(json['affectedDevices'] ?? []),
      createdBy:          json['createdBy'] ?? '',
      timestamp:          DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      description:        json['description'] ?? '',
      associatedLocation: json['associatedLocation'] ?? '',
      relatedReference:   json['relatedReference'] ?? '',
      totalRecords:       json['totalRecords'] as int?,
      successfulRecords:  json['successfulRecords'] as int?,
      failedRecords:      json['failedRecords'] as int?,
      importErrors:       List<String>.from(json['importErrors'] ?? []),
      createdAt:          DateTime.tryParse(json['createdAt'] ?? ''),
    );
  }
}