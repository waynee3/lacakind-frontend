class ContractModel {
  final String id;
  final String contractId;
  final String contractRef;
  final String clientId;
  final String? clientName;
  final String contractType;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> deviceSerials;
  final String status;
  final String paymentStatus;
  final String? notes;
  final String createdBy;
  final DateTime? createdAt;

  const ContractModel({
    required this.id,
    required this.contractId,
    required this.contractRef,
    required this.clientId,
    this.clientName,
    required this.contractType,
    required this.startDate,
    this.endDate,
    this.deviceSerials = const [],
    required this.status,
    required this.paymentStatus,
    this.notes,
    required this.createdBy,
    this.createdAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) => ContractModel(
        id: json['id'] ?? '',
        contractId: json['contractId'] ?? '',
        contractRef: json['contractRef'] ?? '',
        clientId: json['clientId']?['id'] ?? json['clientId'] ?? '',
        clientName: json['clientName'] ?? json['clientId']?['name'],
        contractType: json['contractType'] ?? '',
        startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'])
            : null,
        deviceSerials: List<String>.from(json['deviceSerials'] ?? []),
        status: json['status'] ?? 'Active',
        paymentStatus: json['paymentStatus'] ?? 'Not Paid',
        notes: json['notes'],
        createdBy: json['createdBy'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'contractId': contractId,
        'clientId': clientId,
        'contractType': contractType,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'deviceSerials': deviceSerials,
        'status': status,
        'paymentStatus': paymentStatus,
        if (notes != null) 'notes': notes,
        'createdBy': createdBy,
      };
}