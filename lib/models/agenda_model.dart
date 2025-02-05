class AgendaModel {
  String title;
  String? category;
  bool status;
  DateTime deadline;
  bool selected;

  AgendaModel({
    required this.title,
    this.category,
    required this.status,
    required this.deadline,
    this.selected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'selected': selected,
    };
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      title: json['title'],
      category: json['category'],
      status: json['status'],
      deadline: DateTime.parse(json['deadline']),
      selected: json['selected'] ?? false,
    );
  }
}
