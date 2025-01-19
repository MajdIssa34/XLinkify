class Notification {
  final String id;
  final String fromUsername;
  final String fromProfileImg;
  final String to;
  final String type;
  final bool read;
  final String description; // New field for the notification description
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.fromUsername,
    required this.fromProfileImg,
    required this.to,
    required this.type,
    required this.read,
    required this.description,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      fromUsername: json['from']['username'], // Access username from "from"
      fromProfileImg: json['from']['profileImg'], // Access profileImg from "from"
      to: json['to'],
      type: json['type'],
      read: json['read'] ?? false,
      description: json['description'], // Include description
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': {
        'username': fromUsername,
        'profileImg': fromProfileImg,
      },
      'to': to,
      'type': type,
      'read': read,
      'description': description, // Include description
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
