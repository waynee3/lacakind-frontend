class LogModel {
  final String eventType;
  final DateTime timestamp;
  final String? description;
  final String? associatedLocation;
  final String? responsibleParty;
  final String? relatedReference;
  final int? durationSinceLastEvent;

  const LogModel({
    required this.eventType,
    required this.timestamp,
    this.description,
    this.associatedLocation,
    this.responsibleParty,
    this.relatedReference,
    this.durationSinceLastEvent,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        eventType: json['eventType'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        description: json['description'],
        associatedLocation: json['associatedLocation'],
        responsibleParty: json['responsibleParty'],
        relatedReference: json['relatedReference'],
        durationSinceLastEvent: json['durationSinceLastEvent'],
      );

  Map<String, dynamic> toJson() => {
        'eventType': eventType,
        'timestamp': timestamp.toIso8601String(),
        if (description != null) 'description': description,
        if (associatedLocation != null) 'associatedLocation': associatedLocation,
        if (responsibleParty != null) 'responsibleParty': responsibleParty,
        if (relatedReference != null) 'relatedReference': relatedReference,
      };
}