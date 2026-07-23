class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'completed'
  final String priority; // 'low', 'medium', 'high'
  final DateTime? dueDate;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String parsedUserId = '';
    if (json['user'] != null) {
      if (json['user'] is Map) {
        parsedUserId = json['user']['_id'] ?? '';
      } else {
        parsedUserId = json['user'].toString();
      }
    } else if (json['userId'] != null) {
      parsedUserId = json['userId'].toString();
    }

    return TaskModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      userId: parsedUserId,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  // Convert TaskModel to payload JSON for backend create/update (excludes backend read-only fields)
  Map<String, dynamic> toPayloadJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }

  // Convert TaskModel to full JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper method to create a copy of TaskModel with some updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
