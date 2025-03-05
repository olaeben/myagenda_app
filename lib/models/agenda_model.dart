import 'package:hive/hive.dart';

part 'agenda_model.g.dart';

@HiveType(typeId: 0)
class AgendaModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? category;

  @HiveField(2)
  bool status;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  bool selected;

  @HiveField(5)
  String? description;

  @HiveField(6)
  DateTime createdAt;

  AgendaModel({
    required this.title,
    this.category,
    required this.status,
    required this.deadline,
    this.selected = false,
    this.description,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'selected': selected,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      title: json['title'],
      category: json['category'],
      status: json['status'],
      deadline: DateTime.parse(json['deadline']),
      selected: json['selected'] ?? false,
      description: json['description'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
