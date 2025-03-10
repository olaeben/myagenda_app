import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
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

  @HiveField(7)
  String notificationFrequency;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  String? id;

  AgendaModel({
    this.id,
    required this.title,
    this.category,
    required this.status,
    required this.deadline,
    this.selected = false,
    this.description,
    DateTime? createdAt,
    this.notificationFrequency = 'Daily',
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'selected': selected,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'notificationFrequency': notificationFrequency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      status: json['status'],
      deadline: DateTime.parse(json['deadline']),
      selected: json['selected'] ?? false,
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notificationFrequency: json['notificationFrequency'] ?? 'Daily',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Add a method to show agenda details
  void showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (description != null)
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 16),
                Text(
                  'Deadline: ${DateFormat('MMM d, y - h:mm a').format(deadline)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Status: ${status ? 'Completed' : 'Pending'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Notification Frequency: $notificationFrequency',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
