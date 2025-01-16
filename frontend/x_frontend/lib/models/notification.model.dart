class Notification {
  final String id;
  final String from;
  final String to;
  final String type;
  final bool read;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      from: json['from'],
      to: json['to'],
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'to': to,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
