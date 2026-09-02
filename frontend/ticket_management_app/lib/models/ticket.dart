class Ticket {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;

  final int? createdBy;
  final String? createdByUsername;

  final int? assignedTo;
  final String? assignedUsername;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.createdBy,
    this.createdByUsername,
    this.assignedTo,
    this.assignedUsername,
  });

  // ==================================================
  // FROM JSON
  // ==================================================

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'].toString(),

      title: json['title'] ?? '',

      description: json['description'] ?? '',

      priority: json['priority'] ?? '',

      status: json['status'] ?? '',

      createdBy: json['created_by'] != null
          ? int.tryParse(json['created_by'].toString())
          : null,

      createdByUsername: json['created_by_username'],

      assignedTo: json['assigned_to'] != null
          ? int.tryParse(json['assigned_to'].toString())
          : null,

      assignedUsername: json['assigned_username'],
    );
  }

  // ==================================================
  // TO JSON
  // ==================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
    };
  }
}
