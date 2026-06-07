class RepairModel {
  final String id;
  final String deviceSerial;
  final String issueType;
  final String issueSummary;
  final DateTime dateReported;
  final String status;
  final String createdBy;
  final String? clientRef;
  final String? assignedTo;
  final String? diagnosticNotes;
  final String? repairActions;
  final DateTime? repairCompletedDate;
  final bool spareUsed;
  final String? spareSerial;

  const RepairModel({
    required this.id,
    required this.deviceSerial,
    required this.issueType,
    required this.issueSummary,
    required this.dateReported,
    required this.status,
    required this.createdBy,
    this.clientRef,
    this.assignedTo,
    this.diagnosticNotes,
    this.repairActions,
    this.repairCompletedDate,
    this.spareUsed = false,
    this.spareSerial,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) => RepairModel(
        id: json['id'] ?? '',
        deviceSerial: json['deviceSerial'] ?? '',
        issueType: json['issueType'] ?? '',
        issueSummary: json['issueSummary'] ?? '',
        dateReported: DateTime.tryParse(json['dateReported'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? 'Awaiting Pickup',
        createdBy: json['createdBy'] ?? '',
        clientRef: json['clientRef'],
        assignedTo: json['assignedTo'],
        diagnosticNotes: json['diagnosticNotes'],
        repairActions: json['repairActions'],
        repairCompletedDate: json['repairCompletedDate'] != null
            ? DateTime.tryParse(json['repairCompletedDate'])
            : null,
        spareUsed: json['spareUsed'] ?? false,
        spareSerial: json['spareSerial'],
      );

  Map<String, dynamic> toJson() => {
        'deviceSerial': deviceSerial,
        'issueType': issueType,
        'issueSummary': issueSummary,
        'dateReported': dateReported.toIso8601String(),
        'status': status,
        'createdBy': createdBy,
        if (clientRef != null) 'clientRef': clientRef,
        if (assignedTo != null) 'assignedTo': assignedTo,
        if (diagnosticNotes != null) 'diagnosticNotes': diagnosticNotes,
        if (repairActions != null) 'repairActions': repairActions,
        if (repairCompletedDate != null)
          'repairCompletedDate': repairCompletedDate!.toIso8601String(),
        'spareUsed': spareUsed,
        if (spareSerial != null) 'spareSerial': spareSerial,
      };
}