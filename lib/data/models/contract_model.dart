class ContractModel {
  final String id;
  final String contractId;
  final String contractRef;
  final String clientId;
  final String? clientName;
  final String? clientLocation;
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
    this.clientLocation,
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

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final rawClient = json['clientId'];
    final String parsedClientId;
    final String? parsedClientName;
    final String? parsedClientLocation;

    if (rawClient is Map) {
      parsedClientId       = rawClient['id']?.toString() ??
                             rawClient['_id']?.toString() ?? '';
      parsedClientName     = rawClient['name'] as String?;
      parsedClientLocation = rawClient['location'] as String?;
    } else {
      parsedClientId       = rawClient?.toString() ?? '';
      parsedClientName     = null;
      parsedClientLocation = null;
    }

    return ContractModel(
      id:              json['id'] ?? json['_id']?.toString() ?? '',
      contractId:      json['contractId'] ?? '',
      contractRef:     json['contractRef'] ?? '',
      clientId:        parsedClientId,
      clientName:      json['clientName'] ?? parsedClientName,
      clientLocation:  parsedClientLocation,
      contractType:    json['contractType'] ?? '',
      startDate:       DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:         json['endDate'] != null
                         ? DateTime.tryParse(json['endDate'].toString())
                         : null,
      deviceSerials:   List<String>.from(json['deviceSerials'] ?? []),
      status:          json['status'] ?? 'Active',
      paymentStatus:   json['paymentStatus'] ?? 'Not Paid',
      notes:           json['notes'] as String?,
      createdBy:       json['createdBy'] ?? '',
      createdAt:       json['createdAt'] != null
                         ? DateTime.tryParse(json['createdAt'].toString())
                         : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'contractId':  contractId,
        'clientId':    clientId,
        'contractType': contractType,
        'startDate':   startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'deviceSerials': deviceSerials,
        'status':      status,
        'paymentStatus': paymentStatus,
        if (notes != null) 'notes': notes,
        'createdBy':   createdBy,
      };
}