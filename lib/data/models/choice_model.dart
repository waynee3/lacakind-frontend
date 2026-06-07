class ChoiceModel {
  final String id;
  final String type;
  final String value;
  final String name;

  const ChoiceModel({
    required this.id,
    required this.type,
    required this.value,
    required this.name,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) => ChoiceModel(
        id: json['id'] ?? '',
        type: json['type'] ?? '',
        value: json['value'] ?? '',
        name: json['name'] ?? '',
      );
}